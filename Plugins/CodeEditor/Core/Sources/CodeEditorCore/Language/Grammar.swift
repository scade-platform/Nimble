//
//  Grammar.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.07.19.
//

import AppKit

public final class GrammarDefinition: Grammar {
  private enum CodingKeys: String, CodingKey {
    case scopeName, fileTypes, foldingStartMarker, foldingEndMarker, firstLineMatch
  }
  
  public let scope: GrammarScope?
  public let fileTypes: [String]
  
  public let foldingStartMarker: MatchRegex?
  public let foldingEndMarker: MatchRegex?
  
  public let firstLineMatch: MatchRegex?
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.scope = try GrammarScope(container.decode(String?.self, forKey: .scopeName))
    self.fileTypes = try container.decode([String]?.self, forKey: .fileTypes) ?? []
    self.foldingStartMarker = try container.decode(MatchRegex?.self, forKey: .foldingStartMarker)
    self.foldingEndMarker = try container.decode(MatchRegex?.self, forKey: .foldingEndMarker)
    self.firstLineMatch = try container.decode(MatchRegex?.self, forKey: .firstLineMatch)
    
    try super.init(from: decoder)
  }
}

// MARK: Scope

public struct GrammarScope {
  public var value: String
  
  public init(_ value: String) {
    self.value = value
  }
  
  public init?(_ value: String?) {
    guard let val = value else { return nil }
    self.value = val
  }
}

extension GrammarScope: Hashable {
  public static func == (lhs: GrammarScope, rhs: GrammarScope) -> Bool {
    return lhs.value == rhs.value
  }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}


// MARK: References
public enum GrammarRef {
  case this
  case base
  case local(String)
  case global(GrammarScope, String?)
  
  public init?(_ value: String) {
    switch value {
    case "$self":
      self = .this
    case "$base":
      self = .base
    default:
      if let sep = value.index(of: "#") {
        let key = String(value.suffix(from: value.index(after: sep)))
        let scope = String(value.prefix(upTo: sep))
        
        if scope == "" {
          self = .local(key)
        } else {
          self = .global(GrammarScope(scope), key)
        }
      } else if value != "" {
        self = .global(GrammarScope(value), nil)
      } else {
        return nil
      }
    }
  }
}

// MARK: Content

public class Grammar: Decodable {
  private enum CodingKeys: String, CodingKey {
    case patterns, repository
  }
  
  public let patterns: [Pattern]
  public let repository: [String: Grammar]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.patterns = try container.decode([Pattern]?.self, forKey: .patterns) ?? []
    self.repository = try container.decode([String: Grammar]?.self, forKey: .repository) ?? [:]
  }
  
  
  // MARK: -
  
  public enum Pattern: Decodable {
    private enum CodingKeys: String, CodingKey {
      case include, match, end, `while`
    }
    
    case include(IncludePattern)
    case match(MatchPattern)
    case beginEnd(BeginEndPattern)
    case beginWhile(BeginWhilePattern)
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      if container.contains(.include) {
        self = try .include(.init(from: decoder))
      } else if (container.contains(.match)) {
        self = try .match(.init(from: decoder))
      } else if (container.contains(.end)) {
        self = try .beginEnd(.init(from: decoder))
      } else if (container.contains(.while)) {
        self = try .beginWhile(.init(from: decoder))
      } else {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                debugDescription: "Cannot recognize match pattern"))
      }
    }
  }
  
  // MARK: -
  
  public class PatternRule: Decodable {
    private enum CodingKeys: String, CodingKey {
      case comment, disabled
    }
    
    public let comment: String
    public let disabled: Bool
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      self.comment = try container.decode(String?.self, forKey: .comment) ?? ""
      self.disabled = try container.decode(Bool?.self, forKey: .disabled) ?? false
    }
  }

  // MARK: -
  
  public class IncludePattern: PatternRule {
    private enum CodingKeys: String, CodingKey {
      case include
    }
    
    public let ref: GrammarRef?
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.ref = try GrammarRef(container.decode(String.self, forKey: .include))
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class MatchRule: PatternRule {
    private enum CodingKeys: String, CodingKey {
      case name
    }
    
    public let name: MatchScope
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decode(MatchScope.self, forKey: .name)
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class MatchPattern: MatchRule {
    private enum CodingKeys: String, CodingKey {
      case match, capture
    }
    
    public let match: MatchRegex
    public let capture: [String: MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.match = try container.decode(MatchRegex.self, forKey: .match)
      self.capture = try container.decode([String: MatchCapture]?.self, forKey: .capture) ?? [:]
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class RangeMatchPattern: MatchRule {
    private enum CodingKeys: String, CodingKey {
      case captureName
    }
    
    public let captureName: MatchScope
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.captureName = try container.decode(MatchScope.self, forKey: .captureName)
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class BeginEndPattern: RangeMatchPattern {
    private enum CodingKeys: String, CodingKey {
      case begin, end, beginCapture, endCapture
    }
    
    public let begin: MatchRegex
    public let end: MatchRegex
    
    public let beginCapture: [String: MatchCapture]
    public let endCapture: [String: MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.begin = try container.decode(MatchRegex.self, forKey: .begin)
      self.end = try container.decode(MatchRegex.self, forKey: .end)
      self.beginCapture = try container.decode([String: MatchCapture]?.self, forKey: .beginCapture) ?? [:]
      self.endCapture = try container.decode([String: MatchCapture]?.self, forKey: .endCapture) ?? [:]
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class BeginWhilePattern: RangeMatchPattern {
    private enum CodingKeys: String, CodingKey {
      case begin, `while`, beginCapture, whileCapture
    }
    
    public let begin: MatchRegex
    public let `while`: MatchRegex
    
    public let beginCapture: [String: MatchCapture]
    public let whileCapture: [String: MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.begin = try container.decode(MatchRegex.self, forKey: .begin)
      self.while = try container.decode(MatchRegex.self, forKey: .while)
      self.beginCapture = try container.decode([String: MatchCapture]?.self, forKey: .beginCapture) ?? [:]
      self.whileCapture = try container.decode([String: MatchCapture]?.self, forKey: .whileCapture) ?? [:]
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public final class MatchRegex: Decodable {
    public let value: String
    public init(from decoder: Decoder) throws {
      self.value = try decoder.singleValueContainer().decode(String.self)
    }
  }
  
  // MARK: -
  
  public final class MatchScope: Decodable {
    public let value: String
    public init(from decoder: Decoder) throws {
      self.value = try decoder.singleValueContainer().decode(String.self)
    }
  }
  
  // MARK: -
  
  public final class MatchCapture: Decodable {
    private enum CodingKeys: String, CodingKey {
      case name, patterns
    }
    
    public let name: MatchScope?
    public let patterns: [Pattern]
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decode(MatchScope?.self, forKey: .name)
      self.patterns = try container.decode([Pattern]?.self, forKey: .patterns) ?? []
    }
  }
  
}


// MARK: Decoders

protocol GrammarDecoder {
  static func decode(from: Path) -> GrammarDefinition?
}


extension YAMLDecoder: GrammarDecoder {
  static func decode(from file: Path) -> GrammarDefinition? {
    guard let content = try? String(contentsOf: file) else { return nil }
    do {
      return try YAMLDecoder().decode(GrammarDefinition.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

extension PropertyListDecoder: GrammarDecoder {
  static func decode(from file: Path) -> GrammarDefinition? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try PropertyListDecoder().decode(GrammarDefinition.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

extension JSONDecoder: GrammarDecoder {
  static func decode(from file: Path) -> GrammarDefinition? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try JSONDecoder().decode(GrammarDefinition.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

