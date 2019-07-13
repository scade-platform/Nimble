//
//  ScopeExtractor.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.07.19.
//

import AppKit
import Oniguruma

public protocol Tokenizer {
  func tokenize(_: String, in: NSRange) -> TokenizerResult
}

public protocol TokenizerRepository: class {
  subscript(ref: GrammarRef) -> Tokenizer? { get }
}

public struct TokenizerResult {
  var tokens: [(NSRange, GrammarScope)] = []
  
  var range: NSRange? {
    return tokens.reduce(nil) {
      guard let res = $0 else { return $1.0 }
      return NSUnionRange(res, $1.0)
    }
  }
  
  mutating func append(_ res: TokenizerResult) {
    tokens.append(contentsOf: res.tokens)
  }
}

// MARK: Grammar rule tokenizer

extension GrammarRule {
  public func createTokenizer(with globalRepo: TokenizerRepository) -> (tokenizer: Tokenizer, repository: [String: Tokenizer])? {
    var localRepo: [String: Tokenizer] = [:]
    
    self.repository.forEach {
      guard let result = $0.value.createTokenizer(with: globalRepo) else { return }
      localRepo[$0.key] = result.tokenizer
      // NOTE: keys are not overrided
      localRepo.merge(result.repository) { (current, _) in current }
    }
    
    return (GrammarRuleTokenizer(self.patterns, with: globalRepo), localRepo)
  }
}


class GrammarRuleTokenizer: Tokenizer {
  var patterns: [GrammarRule.Pattern]
  
  weak var repository: TokenizerRepository?
  
  lazy var tokenizers: [Tokenizer] = {
    guard let repo = self.repository else { return [] }
    return patterns.compactMap{ $0.createTokenizer(with: repo) }
  }()
  
  init (_ patterns: [GrammarRule.Pattern], with repo: TokenizerRepository) {
    self.patterns = patterns
    self.repository = repo
  }
  
  public func tokenize(_ str: String, in range: NSRange) -> TokenizerResult {
    var begin = range.lowerBound
    var result = TokenizerResult()
    
    while(begin < range.upperBound) {
      let line = (str as NSString).lineRange(for: NSRange(begin..<begin))
      result.append(applyTokenizers(tokenizers, to: str, in: line))
      begin = result.range?.upperBound ?? line.upperBound
    }
    
    return result
  }
}


// MARK: Pattern tokenizers

extension Grammar.Pattern {
  func createTokenizer(with repo: TokenizerRepository) -> Tokenizer? {
    switch self {
    case .include(let pattern):
      guard let ref = pattern.ref else { return nil }
      return repo[ref]
    case .match(let pattern):
      return MatchTokenizer(pattern, with: repo)
    case .beginEnd(let pattern):
      return BeginEndTokenizer(pattern, with: repo)
    case .beginWhile(let pattern):
      return BeginWhileTokenizer(pattern, with: repo)
    }
  }
  
}

// MARK: -

class MatchTokenizer: Tokenizer {
  let regex: Regex?
  let tokenizers: [(`var`: String, (name: Grammar.MatchName?, tokenizers: [Tokenizer]))]
  
  init(_ pattern: Grammar.MatchPattern, with repo: TokenizerRepository) {
    self.regex = pattern.match.regex
    self.tokenizers = pattern.capture.map {
      ($0.key, $0.value.createTokenizer(with: repo))
    }
  }
  
  func tokenize(_: String, in: NSRange) -> TokenizerResult {
    let result = TokenizerResult()
    
    //TODO: do a match
    
    return result
  }
}

// MARK: -

class BeginEndTokenizer: Tokenizer {
  init(_ pattern: Grammar.BeginEndPattern, with repo: TokenizerRepository?) {
    
  }
  
  func tokenize(_: String, in: NSRange) -> TokenizerResult {
    let result = TokenizerResult()
    return result
  }
}

// MARK: -

class BeginWhileTokenizer: Tokenizer {
  init(_ pattern: Grammar.BeginWhilePattern, with repo: TokenizerRepository?) {
  
  }
  
  func tokenize(_: String, in: NSRange) -> TokenizerResult {
    let result = TokenizerResult()
    return result
  }
}


// MARK: Utilities

fileprivate func applyTokenizers(_ tokenizers: [Tokenizer], to str: String, in range: NSRange) -> TokenizerResult {
  var res = TokenizerResult()
  
  for tokenizer in tokenizers {
    let cur = tokenizer.tokenize(str, in: range)
    if let resRange = res.range {
      if let curRange = cur.range, curRange.lowerBound < resRange.lowerBound {
        res = cur
      }
    } else {
      res = cur
    }
  }
  
  return res
}


// MARK: Extensions

fileprivate var onig_initialized: Bool = false

extension Grammar.MatchRegex {
  typealias Regex = Oniguruma.Regex
  var regex: Regex? {
    if !onig_initialized {
      Oniguruma.initialize()
    }
    return Oniguruma.Regex(value)
  }
}

extension Grammar.MatchCapture {
  func createTokenizer(with repo: TokenizerRepository) -> (name: Grammar.MatchName?, tokenizers: [Tokenizer]) {
    return (name, patterns.compactMap { $0.createTokenizer(with: repo) })
  }
}
