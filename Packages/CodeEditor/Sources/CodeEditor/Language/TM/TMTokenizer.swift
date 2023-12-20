//
//  TMTokenizer.swift
//  CodeEditorCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import NimbleCore

@_implementationOnly import Oniguruma


// MARK: - TMTokenizer

protocol TMTokenizer: Tokenizer {
  typealias SearchResult = (range: Range<Int>, tokenize: () -> TokenizerResult)
  
  func prepare() -> Void
  
  func search(in: TokenizerContext) -> SearchResult?
  
  func tokenize(_: TokenizerContext) -> TokenizerResult?
}


extension TMTokenizer {
  func prepare() { }
  
  func tokenize(_ str: String) -> TokenizerResult? {
    return tokenize(str, in: str.range)
  }
  
  func tokenize(_ str: String, in range: Range<String.Index>) -> TokenizerResult? {
    guard !range.isEmpty,
          let ctx = TokenizerContext(str: str, range: str.utf16(in: range)) else { return nil }

    return tokenize(ctx)
  }
  
  func tokenize(_ ctx: TokenizerContext) -> TokenizerResult? {
    guard let (_, tokenize) = self.search(in: ctx) else { return nil }
    return tokenize()
  }
}


struct TokenizerContext {
  let str: String
  let data: Data
  let range: Range<Int>

  let upperBound: Int
  let isFirstLine: Bool

  init?(str: String, range: Range<Int>, upperBound: Int = -1, isFirstLine: Bool = true) {
    guard let data = str.data(using: .utf16LittleEndian) else { return nil }
    self.init(str: str, data: data, range: range, upperBound: upperBound, isFirstLine: isFirstLine)
  }

  private init(str: String, data: Data, range: Range<Int>, upperBound: Int, isFirstLine: Bool) {
    self.str = str
    self.data = data
    self.range = range

    self.upperBound = upperBound
    self.isFirstLine = isFirstLine
  }


  func with(range: Range<Int>? = nil, upperBound: Int? = nil, isFirstLine: Bool? = nil) -> TokenizerContext {
    return TokenizerContext(str: str,
                            data: data,
                            range: range ?? self.range,
                            upperBound: upperBound ?? self.upperBound,
                            isFirstLine: isFirstLine ?? self.isFirstLine)
  }
}


// MARK: - Grammar Extensions

extension TMGrammar {
  public func createTokenizer(with repo: TokenizerRepository) -> Tokenizer? {
    return GrammarTokenizer(self, with: repo)
  }
  
  func buildRepository(with global: TokenizerRepository) -> [String : Tokenizer] {
    return patterns.buildRepository(with: global, from: buildLocalRepo(with: global))
  }
}

extension TMGrammarRule {
  func buildLocalRepo(with global: TokenizerRepository) -> [String : Tokenizer] {
    return repository.reduce([:]) {
      var r = $0.merging($1.value.buildRepository(with: global)) { (current, _) in current }
      if let t = $1.value.createTokenizer(with: global) {
        r[$1.key] = t
      }
      return r
    }
  }
}

extension Pattern {
  func createTokenizer(with repo: TokenizerRepository) -> TMTokenizer? {
    switch self {
    case .include(let p):
      return IncludeTokenizer(p, with: repo)
      
    case .match(let p):
      return MatchTokenizer(p, with: repo)
      
    case .beginEnd(let p):
      return BeginEndTokenizer(p, with: repo)
      
    case .beginWhile(let p):
      return BeginWhileTokenizer(p, with: repo)
      
    case .patterns(let p):
      return PatternsListTokenizer(p, with: repo)
    }
  }
  
  func buildRepository(with global: TokenizerRepository) -> [String : Tokenizer] {
    switch self {
    case .include(let p):
      return p.buildLocalRepo(with: global)
      
    case .match(let p):
      return p.buildLocalRepo(with: global)
      
    case .beginEnd(let p):
      return p.patterns.buildRepository(with: global, from: p.buildLocalRepo(with: global))
      
    case .beginWhile(let p):
      return p.patterns.buildRepository(with: global, from: p.buildLocalRepo(with: global))
      
    case .patterns(let p):
      return p.patterns.buildRepository(with: global, from: p.buildLocalRepo(with: global))
    }
  }
}


fileprivate extension Array where Element == Pattern {
  func buildRepository(with global: TokenizerRepository, from local: [String : Tokenizer] = [:]) -> [String : Tokenizer] {
    return self.reduce(local) {
      return $0.merging($1.buildRepository(with: global)) { (current, _) in current }
    }
  }
}


// MARK: - Tokenizers

class PatternsListTokenizer: TMTokenizer {
  let tokenizers: [TMTokenizer]

  init (_ pattern: PatternsList , with repo: TokenizerRepository) {
    self.tokenizers = pattern.patterns.compactMap { $0.createTokenizer(with: repo) }
  }

  func search(in ctx: TokenizerContext) -> SearchResult? {
    return searchMatchingTokenizer(tokenizers, in: ctx)
  }

  open func tokenize(_ ctx: TokenizerContext) -> TokenizerResult? {
    guard let (_, tokenize) = self.search(in: ctx) else { return nil }
    return tokenize()
  }
}


class GrammarTokenizer: PatternsListTokenizer {
  override func tokenize(_ ctx: TokenizerContext) -> TokenizerResult? {

//    print("Tokenize range: \(ctx.range)")

    let lines = ctx.str.utf16.lines(from: ctx.range)

//    lines.forEach {
//      print("Line: \($0)")
//    }

    var linesRes = [TokenizerResult?](repeating: nil, count: lines.count)

    DispatchQueue.concurrentPerform(iterations: lines.count) {
      linesRes[$0] = applyTokenizers(tokenizers, to: ctx.with(range: lines[$0]))
    }

//    for i in 0..<lines.count {
//      linesRes[i] = applyTokenizers(tokenizers, to: str, with: ctx.with(range: lines[i]))
//    }

    var result: TokenizerResult? = nil

    for lineRes in linesRes {
      guard let res = result else {
        result = lineRes
        continue
      }

      if let lineRes = lineRes {
        merge(lineRes.disjoint(from: res), into: &result)
      }
    }

    return result
  }
  
//  override func tokenize(_ str: String, with ctx: TokenizerContext) -> TokenizerResult? {
//    var result: TokenizerResult? = nil
//
//    var line = str.utf16.lineRange(at: ctx.range.lowerBound)
//    line = max(ctx.range.lowerBound, line.lowerBound)..<line.upperBound
//
//    while(line.lowerBound < ctx.range.upperBound && (ctx.upperBound < 0 || line.lowerBound < ctx.upperBound)) {
//      let res = applyTokenizers(tokenizers, to: str, with: ctx.with(range: line))
//      merge(res, into: &result)
//
//      if let res = result, res.range.upperBound > line.upperBound {
//        line = res.range.upperBound..<str.utf16.lineEnd(at: res.range.upperBound)
//      } else {
//        line = str.utf16.lineRange(at: line.upperBound)
//      }
//    }
//
//    return result
//  }
}


// MARK: - Include

class IncludeTokenizer: TMTokenizer {
  var ref: GrammarRef
  weak var repo: TokenizerRepository?
  
  // Emulate a lazy weak variable
  private var _init: Bool = false
  private var _queue: DispatchQueue = DispatchQueue(label: "com.nimble.IncludeTokenizer")
  private weak var _tokenizer: TMTokenizer? = nil
    
  var tokenizer: TMTokenizer? {
    return _queue.sync {
      if !self._init {
        //TODO: integrate other types of tokenizers
        self._tokenizer = repo?[ref] as? TMTokenizer
        self._init = true
      }
      return self._tokenizer
    }
  }
  
  init?(_ pattern: IncludePattern, with repo: TokenizerRepository) {
    guard let ref = pattern.ref else { return nil }
    self.ref = ref
    self.repo = repo
  }
      
  func search(in ctx: TokenizerContext) -> TMTokenizer.SearchResult? {
    guard let t = tokenizer else { return nil }
    return t.search(in: ctx)
  }
  
  public func prepare() {
    guard let t = tokenizer else { return }
    t.prepare()
  }
}


// MARK: - Match

typealias CaptureTokenizer = (`var`: MatchCapture.MatchGroup, (name: MatchName?, tokenizers: [TMTokenizer]))

class MatchTokenizer: TMTokenizer {
  let name: MatchName?
  let match: MatchRegex
  let tokenizers: [CaptureTokenizer]
  
  init(_ pattern: MatchPattern, with repo: TokenizerRepository) {
    self.name = pattern.name
    self.match = pattern.match
    self.tokenizers = pattern.captures.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
  }
      
  func search(in ctx: TokenizerContext) -> SearchResult? {
    guard let regex = match.get(allowA: ctx.isFirstLine, allowG: true),
          let res = regex.search(ctx.data, in: ctx.range),
          ctx.upperBound < 0 || res.range.lowerBound < ctx.upperBound else { return nil }
    
    return (res.range, {
      var nodes = applyCaptureTokenizers(self.tokenizers, to: ctx, with: res)

      if let scope = self.name?.resolve(in: ctx.str, with: res) {
        nodes.append(SyntaxNode(range: res.range, data: scope))
      }

      return TokenizerResult(nodes: nodes)
    })
  }
}


// MARK: -

class RangeTokenizer {
  let name: MatchName?
  let contentName: MatchName?
  
  let contentTokenizers: [TMTokenizer]
  
  let begin: MatchRegex
  let beginTokenizers: [CaptureTokenizer]
  
  let pattern: RangeMatchPattern
  
  init(_ pattern: RangeMatchPattern, with repo: TokenizerRepository) {
    self.name = pattern.name
    self.contentName = pattern.contentName
    
    self.contentTokenizers = pattern.patterns.compactMap {
      $0.createTokenizer(with: repo)
    }
    
    self.begin = pattern.begin
    self.beginTokenizers = pattern.beginCaptures.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
    
    //TODO: remove
    self.pattern = pattern
  }
}

// MARK: - BeginEnd

class BeginEndTokenizer: RangeTokenizer, TMTokenizer {
  let end: MatchRegex
  let endTokenizers: [CaptureTokenizer]

  init(_ pattern: BeginEndPattern, with repo: TokenizerRepository) {
    self.end = pattern.end
    self.endTokenizers = pattern.endCaptures.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
    
    super.init(pattern, with: repo)
  }
  
  
  func search(in ctx: TokenizerContext) -> SearchResult? {
    /// A match has to start before the `upperBound` if it's larger than `range.lowerBound`
    guard let regex = self.begin.get(allowA: ctx.isFirstLine, allowG: true),
          let res = regex.search(ctx.data, in: ctx.range),
          ctx.upperBound < 0 || res.range.lowerBound < ctx.upperBound else { return nil }
    
    return (res.range, {
      return self.tokenize(ctx, from: res)
    })
  }
  
  func tokenize(_ ctx: TokenizerContext, from beginRes: Regex.SearchResult) -> TokenizerResult {
    var isFirstLine = ctx.isFirstLine
    
    let begin = beginRes.range
    
    // Setup search space starting from begin and up to the current line's end
    var line = begin.upperBound..<ctx.str.utf16.lineEnd(at: begin.upperBound)
    var (end, endRes) = findEnd(ctx.with(range: line), isBegin: true)
    
    var content: TokenizerResult? = nil
              
    while(line.lowerBound < end.lowerBound) {
      while true {
        let res = applyTokenizers(contentTokenizers, to: ctx.with(range: line, upperBound: end.lowerBound))
        merge(res, into: &content)
        
        if let res = res, res.range.upperBound >= end.upperBound {
          line = res.range.upperBound..<ctx.str.utf16.lineEnd(at: res.range.upperBound)
          (end, endRes) = findEnd(ctx.with(range: line, isFirstLine: isFirstLine), isBegin: false)
        } else {
          break
        }
      }
              
      line = ctx.str.utf16.lineRange(at: line.upperBound)
      isFirstLine = false
    }
    
    
    
    var nodes: [SyntaxNode] = []

    if let scope = name?.resolve() {
      nodes.append(SyntaxNode(range: begin.lowerBound..<end.upperBound, data: scope))
    }


    // Begin node
    if !begin.isEmpty{
      nodes.append(contentsOf: applyCaptureTokenizers(beginTokenizers, to: ctx, with: beginRes))
    }

    
    // Content node
    nodes.append(contentsOf: content?.nodes ?? [])

    if let scope = contentName?.resolve() {
      nodes.append(SyntaxNode(range: begin.upperBound..<end.lowerBound, data: scope))
    }


    // End node
    if !end.isEmpty, let endRes = endRes {
      nodes.append(contentsOf: applyCaptureTokenizers(endTokenizers, to: ctx, with: endRes))
    }
    

    return TokenizerResult(nodes: nodes)
  }
  
    
  func findEnd(_ ctx: TokenizerContext, isBegin: Bool) -> (Range<Int>, Regex.SearchResult?) {
    var isFirstLine = ctx.isFirstLine

    if let regex = self.end.get(allowA: isFirstLine, allowG: isBegin) {
      var line = ctx.range
      while(line.lowerBound < ctx.str.utf16.count) {
        if let res = regex.search(ctx.data, in: line) {
          return (res.regs[0], res)
        }
        line = ctx.str.utf16.lineRange(at: line.upperBound)
        isFirstLine = false
      }
    }
    return (ctx.str.utf16.count..<ctx.str.utf16.count, nil)
  }
  
}



// MARK: - BeginWhile

class BeginWhileTokenizer: RangeTokenizer, TMTokenizer {
  let `while`: MatchRegex
  let whileTokenizers: [CaptureTokenizer]

  init(_ pattern: BeginWhilePattern, with repo: TokenizerRepository) {
    self.while = pattern.while
    self.whileTokenizers = pattern.whileCapture.map {
      ($0.key, $0.createTokenizer(with: repo))
    }
    super.init(pattern, with: repo)
  }
  
  func search(in ctx: TokenizerContext) -> SearchResult? {
    return nil
  }
}


// MARK: - Utilities

fileprivate func merge(_ res1: TokenizerResult?, into res2: inout TokenizerResult?) -> Void {
  guard let res1 = res1 else { return }
  if var res = res2 {
    res.range = res.range.union(with: res1.range)
    res.nodes.append(contentsOf: res1.nodes)
    res2 = res
  } else {
    res2 = res1
  }
}


fileprivate func searchMatchingTokenizer(_ tokenizers: [TMTokenizer], in ctx: TokenizerContext) -> TMTokenizer.SearchResult? {
  var result: TMTokenizer.SearchResult? = nil
  
  for t in tokenizers {
    guard let cur = t.search(in: ctx) else { continue }
    if cur.range.lowerBound == ctx.range.lowerBound {
      return cur
    }
    
    guard let res = result else { result = cur; continue }
    if cur.range.lowerBound < res.range.lowerBound {
      result = cur
    }
  }

  return result
}


fileprivate func applyTokenizers(_ tokenizers: [TMTokenizer], to ctx: TokenizerContext) -> TokenizerResult? {
  
  var result: TokenizerResult? = nil
  var begin = ctx.range.lowerBound
  
  while begin < ctx.range.upperBound && (ctx.upperBound < 0 || begin < ctx.upperBound) {
    let ctx = ctx.with(range: begin..<ctx.range.upperBound)
    guard let (_, tokenize) = searchMatchingTokenizer(tokenizers, in: ctx) else { break }
    
    let cur = tokenize()
    
    merge(cur, into: &result)
    
    if begin < cur.range.upperBound {
      begin = cur.range.upperBound
    } else {
      begin += 1
    }
  }

  return result
}


fileprivate func applyCaptureTokenizers(_ tokenizers: [CaptureTokenizer],
                                        to ctx: TokenizerContext,
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
    
    for r in regs where !r.isEmpty {
      // TODO: check if we need to set ctx params (except range) to default
      let tRes = applyTokenizers(t.1.tokenizers, to: ctx.with(range: r))

      if let scope = t.1.name?.resolve(in: ctx.str, with: res) {
        nodes.append(SyntaxNode(range: r, data: scope))
      }

      nodes.append(contentsOf: tRes?.nodes ?? [] )
    }
  }
  
  return nodes
}



// MARK: - Match Extensions

extension MatchCapture {
  func createTokenizer(with repo: TokenizerRepository) -> (name: MatchName?, tokenizers: [TMTokenizer]) {
    return (name, patterns.compactMap { $0.createTokenizer(with: repo) })
  }
}

extension MatchName {
  func resolve(`in` str: String? = nil, with result: Oniguruma.Regex.SearchResult? = nil) -> SyntaxScope {
    guard let regex = nameRegex, let str = str, let res = result, res.regs.count > 0 else {
       return SyntaxScope(self.value)
    }
        
    var name = self.value
    
    regex.enumerateMatches(in: self.value, options: [], range: self.value.nsRange) { (match, _, _) in
      guard let match = match else { return }

      let r0 = match.range(at: 0)
      let r1 = match.range(at: 1)
      
      guard let i = Int((self.value as NSString).substring(with: r1)), i < res.regs.count else { return }
      
      let r = name.index(at: r0.lowerBound)..<name.index(at: r0.upperBound)
      let repl = str.chars(utf16: res.regs[i])
      
      name.replaceSubrange(r, with: str[repl])
    }
    
    return SyntaxScope(name)
  }
}


fileprivate let nameRegex = try? NSRegularExpression(pattern: "\\$([0-9]+)", options: [])
