//
//  Grammar.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.07.19.
//

import AppKit



// MARK: Grammar

public final class Grammar: GrammarRule {
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
    
    self.scope = try GrammarScope(container.decodeIfPresent(String.self, forKey: .scopeName))
    self.fileTypes = try container.decodeIfPresent([String].self, forKey: .fileTypes) ?? []
    self.foldingStartMarker = try container.decodeIfPresent(MatchRegex.self, forKey: .foldingStartMarker)
    self.foldingEndMarker = try container.decodeIfPresent(MatchRegex.self, forKey: .foldingEndMarker)
    self.firstLineMatch = try container.decodeIfPresent(MatchRegex.self, forKey: .firstLineMatch)
    
    try super.init(from: decoder)
  }
}


// MARK: Grammar rule consisting of the set of patterns

public class GrammarRule: Decodable {
  private enum CodingKeys: String, CodingKey {
    case patterns, repository
  }
  
  public let patterns: [Pattern]
  public let repository: [String: GrammarRule]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.patterns = try container.decodeIfPresent([Pattern].self, forKey: .patterns) ?? []
    self.repository = try container.decodeIfPresent([String: GrammarRule].self, forKey: .repository) ?? [:]
  }
  

  // MARK: Content types
  
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
      
      self.comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
      self.disabled = try container.decodeIfPresent(Bool.self, forKey: .disabled) ?? false
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
    
    public let name: MatchName?
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decodeIfPresent(MatchName.self, forKey: .name)
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
      self.capture = try container.decodeIfPresent([String: MatchCapture].self, forKey: .capture) ?? [:]
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class RangeMatchPattern: MatchRule {
    private enum CodingKeys: String, CodingKey {
      case contentName
    }
    
    public let contentName: MatchName?
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.contentName = try container.decodeIfPresent(MatchName.self, forKey: .contentName)
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
      self.beginCapture = try container.decodeIfPresent([String: MatchCapture].self, forKey: .beginCapture) ?? [:]
      self.endCapture = try container.decodeIfPresent([String: MatchCapture].self, forKey: .endCapture) ?? [:]
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
      self.beginCapture = try container.decodeIfPresent([String: MatchCapture].self, forKey: .beginCapture) ?? [:]
      self.whileCapture = try container.decodeIfPresent([String: MatchCapture].self, forKey: .whileCapture) ?? [:]
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public struct MatchRegex: Decodable {
    public let value: String
    public init(from decoder: Decoder) throws {
      self.value = try decoder.singleValueContainer().decode(String.self)
    }
  }
  
  // MARK: -
  
  public struct MatchName: Decodable {
    public let value: String
    public init(from decoder: Decoder) throws {
      self.value = try decoder.singleValueContainer().decode(String.self)
    }
  }
  
  // MARK: -
  
  public struct MatchCapture: Decodable {
    private enum CodingKeys: String, CodingKey {
      case name, patterns
    }
    
    public let name: MatchName?
    public let patterns: [Pattern]
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decodeIfPresent(MatchName.self, forKey: .name)
      self.patterns = try container.decodeIfPresent([Pattern].self, forKey: .patterns) ?? []
    }
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

// MARK: Decoders

protocol GrammarDecoder {
  static func decode(from: Path) -> Grammar?
}


extension YAMLDecoder: GrammarDecoder {
  static func decode(from file: Path) -> Grammar? {
    guard let content = try? String(contentsOf: file) else { return nil }
    do {
      return try YAMLDecoder().decode(Grammar.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

extension PropertyListDecoder: GrammarDecoder {
  static func decode(from file: Path) -> Grammar? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try PropertyListDecoder().decode(Grammar.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

extension JSONDecoder: GrammarDecoder {
  static func decode(from file: Path) -> Grammar? {
    guard let content = try? Data(contentsOf: file) else { return nil }
    
    do {
      return try JSONDecoder().decode(Grammar.self, from: content)
    } catch let error as DecodingError {
      print(error)
      return nil
    } catch {
      return nil
    }
  }
}

