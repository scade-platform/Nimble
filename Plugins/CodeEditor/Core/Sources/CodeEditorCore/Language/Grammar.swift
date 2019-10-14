//
//  Grammar.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.07.19.
//

import AppKit
import Oniguruma


// MARK: Grammar

public final class Grammar: PatternsList {
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
    
    scope = try SyntaxScope(container.decodeIfPresent(String.self, forKey: .scopeName))
    fileTypes = try container.decodeIfPresent([String].self, forKey: .fileTypes) ?? []
    foldingStartMarker = try container.decodeIfPresent(MatchRegex.self, forKey: .foldingStartMarker)
    foldingEndMarker = try container.decodeIfPresent(MatchRegex.self, forKey: .foldingEndMarker)
    firstLineMatch = try container.decodeIfPresent(MatchRegex.self, forKey: .firstLineMatch)
    
    try super.init(from: decoder)
  }
}


// MARK: Grammar rule consisting of the set of patterns

public class GrammarRule: Decodable {
  private enum CodingKeys: String, CodingKey {
    case comment, repository
  }
  
  public let comment: String
  public let repository: [String: Pattern]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
    repository = try container.decodeIfPresent([String: Pattern].self, forKey: .repository) ?? [:]
  }
}



// MARK: Content types

public enum Pattern: Decodable {
  private enum CodingKeys: String, CodingKey {
    case include, match, end, `while`, patterns
  }
  
  case include(IncludePattern)
  case match(MatchPattern)
  case beginEnd(BeginEndPattern)
  case beginWhile(BeginWhilePattern)
  case patterns(PatternsList)
  
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
    } else if (container.contains(.patterns)) {
        self = try .patterns(.init(from: decoder))
    } else {
      throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                              debugDescription: "Cannot recognize match pattern"))
    }
  }
}


// MARK: -

public class PatternsList: GrammarRule {
  private enum CodingKeys: String, CodingKey {
    case patterns
  }
  
  public let patterns: [Pattern]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.patterns = try container.decodeIfPresent([Pattern].self, forKey: .patterns) ?? []
    try super.init(from: decoder)
  }
}
  
  
// MARK: -

public class PatternRule: GrammarRule {
  private enum CodingKeys: String, CodingKey {
    case disabled
  }
    
  public let disabled: Bool
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.disabled = try container.decodeIfPresent(Bool.self, forKey: .disabled) ?? false
    try super.init(from: decoder)
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
    
    let bc = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .beginCaptures) ?? [:]
    self.beginCaptures = bc.map { MatchCapture($0.key, raw: $0.value) }
    
    try super.init(from: decoder)
  }
}

// MARK: -

public class BeginEndPattern: RangeMatchPattern {
  private enum CodingKeys: String, CodingKey {
    case end, endCaptures, name
  }
  
  public let end: MatchRegex
  public let endCaptures: [MatchCapture]
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.end = try container.decode(MatchRegex.self, forKey: .end)
    
    let ec = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .endCaptures) ?? [:]
    self.endCaptures = ec.map { MatchCapture($0.key, raw: $0.value) }
    
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
    
    let wc = try container.decodeIfPresent([String: MatchCapture.Raw].self, forKey: .whileCapture) ?? [:]
    self.whileCapture = wc.map { MatchCapture($0.key, raw: $0.value) }
    
    try super.init(from: decoder)
  }
}
  
// MARK: -

public struct MatchRegex: Decodable {
  public typealias Regex = Oniguruma.Regex
  
  // A0_G0, A0_G1, A1_G0, A1_G1
  private let regex: [Regex?]
  
  private static var onig_initialized: Bool = false
    
  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    
    let values = MatchRegex.resolveAnchors(value)
    var regex = [Regex?](repeating: nil, count: values.count)
    
    if !MatchRegex.onig_initialized {
      Oniguruma.initialize()
      MatchRegex.onig_initialized = true
    }
    
    for (i, v) in values.enumerated() {
      regex[i] = Oniguruma.Regex(v)
    }
    
    self.regex = regex
  }
  
  public func get(allowA: Bool, allowG: Bool) -> Regex? {
    if regex.count == 1 {
      return regex[0]
    }
    
    if allowA {
      return allowG ? regex[3] : regex[2]
    } else if allowG {
      return allowA ? regex[3] : regex[1]
    } else {
      return regex[0]
    }
  }
    
  private static func resolveAnchors(_ str: String) -> [String] {
    var anchors = ["", "", "", ""]
    var hasAnchors = false
    
    var i = 0
    while i < str.count {
      let cur = str[i]
      
      for (j, _) in anchors.enumerated() {
        anchors[j].append(cur)
      }
      
      if cur == "\\" && i + 1 < str.count {
        let next = str[i + 1]
        switch(next) {
        case "A":
          anchors[0].append("\u{FFFF}")
          anchors[1].append("\u{FFFF}")
          anchors[2].append(next)
          anchors[3].append(next)
          hasAnchors = true
        case "G":
          anchors[0].append("\u{FFFF}")
          anchors[1].append(next)
          anchors[2].append("\u{FFFF}")
          anchors[3].append(next)
          hasAnchors = true
        default:
          for (j, _) in anchors.enumerated() {
            anchors[j].append(next)
          }
        }
        i += 1
      }
      i += 1
    }
    return hasAnchors ? anchors  : [str]
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

