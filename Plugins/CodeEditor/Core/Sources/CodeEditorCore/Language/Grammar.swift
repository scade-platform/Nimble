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
  
  public let scope: SyntaxScope?
  public let fileTypes: [String]
  
  public let foldingStartMarker: MatchRegex?
  public let foldingEndMarker: MatchRegex?
  
  public let firstLineMatch: MatchRegex?
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.scope = try SyntaxScope(container.decodeIfPresent(String.self, forKey: .scopeName))
    self.fileTypes = try container.decodeIfPresent([String].self, forKey: .fileTypes) ?? []
    self.foldingStartMarker = try container.decodeIfPresent(MatchRegex.self, forKey: .foldingStartMarker)
    self.foldingEndMarker = try container.decodeIfPresent(MatchRegex.self, forKey: .foldingEndMarker)
    self.firstLineMatch = try container.decodeIfPresent(MatchRegex.self, forKey: .firstLineMatch)
    
    try super.init(from: decoder)
  }
}


// MARK: Grammar rule consisting of the set of patterns

public protocol GrammarRuleProtocol: Decodable {
  var patterns: [GrammarRule.Pattern] { get }
  var repository: [String: GrammarRepositoryEntry] { get }
}

public class GrammarRule: GrammarRuleProtocol {
  private enum CodingKeys: String, CodingKey {
    case patterns, repository, comment
  }
  
  fileprivate static func hasCodingKey(_ key: String) -> Bool {
    return CodingKeys(rawValue: key) != nil
  }
  
  public let patterns: [Pattern]
  public let repository: [String: GrammarRepositoryEntry]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.patterns = try container.decodeIfPresent([Pattern].self, forKey: .patterns) ?? []
    self.repository = try container.decodeIfPresent([String: GrammarRepositoryEntry].self, forKey: .repository) ?? [:]
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
      case match, captures
    }
    
    public let match: MatchRegex
    public let captures: [MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.match = try container.decode(MatchRegex.self, forKey: .match)
      
      let captures = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .captures) ?? [:]
      self.captures = captures.map { MatchCapture($0.key, raw: $0.value) }
      
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class RangeMatchPattern: MatchRule {
    private enum CodingKeys: String, CodingKey {
      case contentName, patterns, begin, beginCaptures
    }
    
    public let contentName: MatchName?
    public let patterns: [Pattern]
    
    public let begin: MatchRegex
    public let beginCaptures: [MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      self.contentName = try container.decodeIfPresent(MatchName.self, forKey: .contentName)
      self.patterns = try container.decodeIfPresent([Pattern].self, forKey: .patterns) ?? []
      
      self.begin = try container.decode(MatchRegex.self, forKey: .begin)
      
      let beginCaptures = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .beginCaptures) ?? [:]
      self.beginCaptures = beginCaptures.map { MatchCapture($0.key, raw: $0.value) }
      
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class BeginEndPattern: RangeMatchPattern {
    private enum CodingKeys: String, CodingKey {
      case end, endCaptures
    }
    
    public let end: MatchRegex
    public let endCaptures: [MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      self.end = try container.decode(MatchRegex.self, forKey: .end)
      let endCaptures = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .endCaptures) ?? [:]
      self.endCaptures = endCaptures.map { MatchCapture($0.key, raw: $0.value) }
      
      try super.init(from: decoder)
    }
  }
  
  // MARK: -
  
  public class BeginWhilePattern: RangeMatchPattern {
    private enum CodingKeys: String, CodingKey {
      case `while`, whileCapture
    }
    
    public let `while`: MatchRegex
    public let whileCapture: [MatchCapture]
    
    public required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      self.while = try container.decode(MatchRegex.self, forKey: .while)
            
      let whileCapture = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .whileCapture) ?? [:]
      self.whileCapture = whileCapture.map { MatchCapture($0.key, raw: $0.value) }
      
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
  
  public struct MatchCapture {
    fileprivate struct Raw: Decodable {
      private enum CodingKeys: String, CodingKey {
        case name, patterns
      }
      
      fileprivate let name: MatchName?
      fileprivate let patterns: [Pattern]
      
      fileprivate init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(MatchName.self, forKey: .name)
        self.patterns = try container.decodeIfPresent([Pattern].self, forKey: .patterns) ?? []
      }
    }
    
    public enum MatchGroup {
      case name(String)
      case index(UInt)
    }
    
    public let key: MatchGroup
    public let name: MatchName?
    public let patterns: [Pattern]
    
    fileprivate init(_ key: String, raw: Raw) {
      if let _idx = UInt(key) {
        self.key = .index(_idx)
      } else {
        self.key = .name(key)
      }
      
      self.name = raw.name
      self.patterns = raw.patterns
    }
    
  }
}

// MARK: GrammarRepositoryEntry

public enum GrammarRepositoryEntry: Decodable {
  case rule(GrammarRule)
  case pattern(GrammarRule.Pattern)
  
  private struct CodingKeys: CodingKey {
    var intValue: Int?
    var stringValue: String
    
    init?(stringValue: String) {
      self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
      return nil
    }
  }
  
  public init (from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let keys = container.allKeys
    
    if keys.allSatisfy( {GrammarRule.hasCodingKey($0.stringValue)} ) {
      self = try .rule(GrammarRule(from: decoder))
    } else {
      self = try .pattern(GrammarRule.Pattern(from: decoder))
    }
  }
}


// MARK: References

public enum GrammarRef {
  case this
  case base
  case local(String)
  case global(SyntaxScope, String?)
  
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
          self = .global(SyntaxScope(scope), key)
        }
      } else if value != "" {
        self = .global(SyntaxScope(value), nil)
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

