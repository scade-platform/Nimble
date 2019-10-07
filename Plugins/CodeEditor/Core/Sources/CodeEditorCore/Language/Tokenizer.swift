//
//  ScopeExtractor.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 04.07.19.
//

import AppKit
import Oniguruma

public protocol Tokenizer: class {
  func tokenize(_: String) -> TokenizerResult
  func tokenize(_: String, in: Range<Int>, upperBound: Int) -> TokenizerResult
  func prepare() -> Void
}

public extension Tokenizer {
  func tokenize(_ str: String) -> TokenizerResult {
    return self.tokenize(str, in: 0..<str.count, upperBound: -1)
  }
  
  func prepare() { }
}

public protocol TokenizerRepository: class {
  subscript(ref: GrammarRef) -> Tokenizer? { get }
}

public struct TokenizerResult {
  var range: Range<Int> = 0..<0
  var nodes: [SyntaxNode] = []
  
  var isEmpty: Bool { return range.isEmpty }
}


// MARK: Grammar and grammar rule tokenizer

extension GrammarRule {
  public func createTokenizer(with globalRepo: TokenizerRepository) -> (tokenizer: Tokenizer, repository: [String: Tokenizer])? {
    var localRepo: [String: Tokenizer] = [:]

    self.repository.forEach {
      guard let result = $0.value.createTokenizer(with: globalRepo) else { return }
      localRepo[$0.key] = result.tokenizer
      // NOTE: keys are not overrided
      localRepo.merge(result.repository) { (current, _) in current }
    }
    
    if self is Grammar {
     return (GrammarTokenizer(self.patterns, with: globalRepo), localRepo)
    } else {
      return (GrammarRuleTokenizer(self.patterns, with: globalRepo), localRepo)
    }
  }
}


// MARK: Repository entry (either Rule or Patters) tokenizer

extension GrammarRepositoryEntry {
  func createTokenizer(with repo: TokenizerRepository) -> (tokenizer: Tokenizer, repository: [String: Tokenizer])? {
    switch self {
    case .rule(let r):
      return r.createTokenizer(with: repo)
    case .pattern(let p):
      guard let t = p.createTokenizer(with: repo) else { return nil }
      return (t, [:])
    }
  }
}

// MARK: Pattern tokenizers

extension Grammar.Pattern {
  func createTokenizer(with repo: TokenizerRepository) -> Tokenizer? {
    switch self {
    case .include(let pattern):
      guard let ref = pattern.ref else { return nil }
      return IncludeTokenizer(ref, with: repo)
      
    case .match(let pattern):
      return MatchTokenizer(pattern, with: repo)
    
    case .beginEnd(let pattern):
      return BeginEndTokenizer(pattern, with: repo)
    
    case .beginWhile(let pattern):
      return BeginWhileTokenizer(pattern, with: repo)
    }
  }
}


// MARK: Tokenizers

class GrammarTokenizer: GrammarRuleTokenizer {
  
  override func tokenize(_ str: String, in range: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
    let t1 = mach_absolute_time()
    
    var result = TokenizerResult(range: range, nodes: [])
    
    let bytes = str.utf8
    let bytesRange = str.utf8(in: range)
    
    var line = bytes.lineRange(at: bytesRange.lowerBound)
    while(line.lowerBound < bytesRange.upperBound) {
      let res = applyTokenizers(tokenizers, to: str, in: line)
      result.nodes.append(contentsOf: res.nodes)

//      result.nodes.append(contentsOf: res.nodes.map {
//        (str.chars(utf8: $0.0), $0.1)
//      })
      
      if res.range.lowerBound > line.upperBound {
        line = res.range.upperBound..<bytes.lineEnd(at: res.range.upperBound)
      } else {
        line = bytes.lineRange(at: line.upperBound)
      }
      
    }
    
    let t2 = mach_absolute_time()
    print("Tokenize time: \( Double(t2 - t1) * 1E-9)")
    
    return result
  }
  
}


class GrammarRuleTokenizer: Tokenizer {
  var patterns: [GrammarRule.Pattern]
  weak var repository: TokenizerRepository?
  
//  var tokenizers: [Tokenizer] = []
  
  lazy var tokenizers: [Tokenizer] = {
    guard let repo = self.repository else { return [] }
    return patterns.compactMap{ $0.createTokenizer(with: repo) }
  }()
  
  required init (_ patterns: [GrammarRule.Pattern], with repo: TokenizerRepository) {
    self.patterns = patterns
    self.repository = repo
  }
  
  open func tokenize(_ str: String, in range: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
    var res = TokenizerResult()
    
    for t in tokenizers {
      let cur = t.tokenize(str, in: range, upperBound: upperBound)
      if !cur.range.isEmpty && (res.range.isEmpty || cur.range.lowerBound < res.range.lowerBound) {
        res = cur
      }
    }
    
    return res
  }
  
//  public func prepare() {
//    guard let repo = self.repository else { return }
//    self.tokenizers = patterns.compactMap{ $0.createTokenizer(with: repo) }
//
//    for t in tokenizers {
//      t.prepare()
//    }
//  }
}


// MARK: -

class IncludeTokenizer: Tokenizer {
  var ref: GrammarRef
  weak var repo: TokenizerRepository?
  
  // Emulate a lazy weak variable
  private var _tokenizerInit: Bool = false
  private weak var _tokenizer: Tokenizer? = nil
  
  var tokenizer: Tokenizer? {
    if !_tokenizerInit {
      _tokenizer = repo?[ref]
      _tokenizerInit = true
    }
    return _tokenizer
  }
  
  init(_ ref: GrammarRef, with repo: TokenizerRepository) {
    self.ref = ref
    self.repo = repo
  }
  
  func tokenize(_ str: String, in range: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
    guard let t = tokenizer else { return TokenizerResult() }
    return t.tokenize(str, in: range, upperBound: upperBound)
  }
  
  public func prepare() {
    guard let t = tokenizer else { return }
    t.prepare()
  }
}


// MARK: -

typealias CaptureTokenizer = (`var`: Grammar.MatchCapture.MatchGroup, (name: Grammar.MatchName?, tokenizers: [Tokenizer]))

class MatchTokenizer: Tokenizer {
  let regex: Regex?
  let name: Grammar.MatchName?
  let tokenizers: [CaptureTokenizer]
  
  init(_ pattern: Grammar.MatchPattern, with repo: TokenizerRepository) {
    self.name = pattern.name
    self.regex = pattern.match.regex
    self.tokenizers = pattern.captures.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
  }
  
  func tokenize(_ str: String, in range: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
    var result = TokenizerResult()
    
    /// A match has to start before the `upperBound` if it's larger than `range.lowerBound`
    if let regex = self.regex, let res = regex.search(str, in: range),
        upperBound < range.lowerBound || res.regs[0].lowerBound < upperBound {
      
      let nodes = applyCaptureTokenizers(tokenizers, to: str, with: res)
      
      result.range = res.regs[0]
      result.nodes.append(
        SyntaxNode(scope: name?.resolve(res), range: result.range, nodes: nodes))
    }
    
    return result
  }
}

// MARK: -

class RangeTokenizer {
  let name: Grammar.MatchName?
  let contentName: Grammar.MatchName?
  
  let contentTokenizers: [Tokenizer]
  
  let begin: Regex?
  let beginTokenizers: [CaptureTokenizer]
  
  init(_ pattern: Grammar.RangeMatchPattern, with repo: TokenizerRepository) {
    self.name = pattern.name
    self.contentName = pattern.contentName
    
    self.contentTokenizers = pattern.patterns.compactMap {
      $0.createTokenizer(with: repo)
    }
    
    self.begin = pattern.begin.regex
    self.beginTokenizers = pattern.beginCaptures.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
    
  }
}

// MARK: -

class BeginEndTokenizer: RangeTokenizer, Tokenizer {
  let end: Regex?
  let endTokenizers: [CaptureTokenizer]

  init(_ pattern: Grammar.BeginEndPattern, with repo: TokenizerRepository) {
    self.end = pattern.end.regex
    self.endTokenizers = pattern.endCaptures.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
    
    super.init(pattern, with: repo)
  }

  func tokenize(_ str: String, in range: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
    var result = TokenizerResult()
    
    /// A match has to start before the `upperBound` if it's larger than `range.lowerBound`
    if let regex = self.begin, let beginRes = regex.search(str, in: range),
        upperBound < range.lowerBound || beginRes.regs[0].lowerBound < upperBound {
      
      let begin = beginRes.regs[0]
      // Setup search space starting from begin and up to the current line's end
      var line = begin.upperBound..<str.utf8.lineEnd(at: begin.upperBound)
      var (end, endRes) = findEnd(str, start: line)
      
      var contentResult = TokenizerResult()
      
      while(line.lowerBound < end.lowerBound) {
        let res = applyTokenizers(self.contentTokenizers, to: str, in: line, upperBound: end.lowerBound)
        
        if contentResult.isEmpty {
          contentResult = res
        } else {
          contentResult.range = contentResult.range.union(res.range)
          contentResult.nodes.append(contentsOf: res.nodes)
        }
        
        line = str.utf8.lineRange(at: line.upperBound)
      }
      
      
      // Content node
      if contentResult.range.upperBound >= end.upperBound {
        line = contentResult.range.upperBound..<str.utf8.lineEnd(at: contentResult.range.upperBound)
        (end, endRes) = findEnd(str, start: line)
      }
      
      let contentNode = SyntaxNode(scope: contentName?.resolve(),
                                   range: begin.upperBound..<end.lowerBound,
                                   nodes: contentResult.nodes)
      
      var nodes = [contentNode]
      
      
      // Begin node
      if !begin.isEmpty{
        let beginNode = SyntaxNode(scope: nil,
                                   range: begin.lowerBound..<begin.upperBound,
                                   nodes: applyCaptureTokenizers(beginTokenizers, to: str, with: beginRes))
        
        nodes.insert(beginNode, at: 0)
      }

      
      // End node
      if !end.isEmpty, let endRes = endRes {
        let endNode = SyntaxNode(scope: nil,
                                 range: end.lowerBound..<end.upperBound,
                                 nodes: applyCaptureTokenizers(endTokenizers, to: str, with: endRes))
        nodes.append(endNode)
      }
      
      
      // Result
      result.range = begin.lowerBound..<end.upperBound
      result.nodes.append(SyntaxNode(scope: name?.resolve(), range: result.range, nodes: nodes))
    }
    
    return result
  }
  
  func findEnd(_ str: String, start from: Range<Int>) -> (Range<Int>, Regex.SearchResult?) {
    if let regex = self.end {
      var line = from
      while(line.lowerBound < str.utf8.count) {
        if let res = regex.search(str, in: line) {
          return (res.regs[0], res)
        }
        line = str.utf8.lineRange(at: line.upperBound)
      }
    }
    return (str.utf8.count..<str.utf8.count, nil)
  }
  
}



// MARK: -

class BeginWhileTokenizer: RangeTokenizer, Tokenizer {
  let `while`: Regex?
  let whileTokenizers: [CaptureTokenizer]

  init(_ pattern: Grammar.BeginWhilePattern, with repo: TokenizerRepository) {
    self.while = pattern.while.regex
    self.whileTokenizers = pattern.whileCapture.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
    super.init(pattern, with: repo)
  }
  
  func tokenize(_: String, in: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
    return TokenizerResult()
  }
}


// MARK: Utilities

fileprivate func applyTokenizers(_ tokenizers: [Tokenizer], to str: String,
                                    in range: Range<Int>, upperBound: Int = -1) -> TokenizerResult {
  
  var res = TokenizerResult(range: range.lowerBound..<range.lowerBound, nodes: [])
  
  var begin = range.lowerBound
  while begin < range.upperBound {
    var pos = begin
    var curRes = TokenizerResult()
    
    for t in tokenizers {
      let cur = t.tokenize(str, in: pos..<range.upperBound, upperBound: upperBound)
      if !cur.range.isEmpty && (curRes.range.isEmpty || cur.range.lowerBound < curRes.range.lowerBound) {
        curRes = cur
        if cur.range.lowerBound == pos {
          break
        }
      }
    }
    
    if !curRes.range.isEmpty {
      res.nodes.append(contentsOf: curRes.nodes)
      res.range = res.range.union(curRes.range)
      pos = curRes.range.upperBound
    }

    // If no tokenizer matched, break
    if pos > begin {
      begin = pos
    } else {
      break
    }
  }

  return res
}


fileprivate func applyCaptureTokenizers(_ tokenizers: [CaptureTokenizer], to str: String,
                                            with res: Regex.SearchResult) -> [SyntaxNode] {
  var nodes: [SyntaxNode] = []
  
  for t in tokenizers {
    var regs: [Range<Int>] = []
    
    switch t.var {
    case .index(let i):
      if i < res.regs.count {
        regs.append(res.regs[Int(i)])
      }
    case .name(let n):
      if let indices = res.names[n] {
        regs = indices.map {res.regs[$0]}
      }
    }
    
    for r in regs where r.lowerBound >= 0 { //where !r.isEmpty {
      let tRes = applyTokenizers(t.1.tokenizers, to: str, in: r)
      nodes.append(
        SyntaxNode(scope: t.1.name?.resolve(res), range: r, nodes: tRes.nodes))
    }
  }
  
  return nodes
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

extension Grammar.MatchName {
  func resolve(_ result: Oniguruma.Regex.SearchResult? = nil) -> SyntaxScope {
    ///TODO: for now just return the value as is
    return SyntaxScope(self.value)
  }
}
