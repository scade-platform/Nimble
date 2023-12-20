//
//  Tokenizer.swift
//  CodeEditorCore
//
//  Copyright © 2023 SCADE Inc. All rights reserved.
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

import Foundation


public protocol Tokenizer: AnyObject {
  func tokenize(_ str: String, in range: Range<String.Index>) -> TokenizerResult?
  func tokenize(_ str: String) -> TokenizerResult?
}

extension Tokenizer {
  func tokenize(_ str: String, in range: NSRange) -> TokenizerResult? {
    tokenize(str, in: range.lowerBound..<range.upperBound)
  }

  func tokenize(_ str: String, in range: Range<Int>) -> TokenizerResult? {
    let begin = str.index(str.startIndex, offsetBy: range.lowerBound, limitedBy: str.endIndex) ?? str.endIndex
    let end = str.index(str.startIndex, offsetBy: range.upperBound, limitedBy: str.endIndex) ?? str.endIndex
    return tokenize(str, in: begin..<end)
  }
}

public struct TokenizerResult {
  var range: Range<Int>
  var nodes: [SyntaxNode]

  var isEmpty: Bool { return range.isEmpty }

  init(range: Range<Int> = 0..<0, nodes: [SyntaxNode] = []) {
    self.range = range
    self.nodes = nodes
  }

  init(location: Int) {
    self.init(range: location..<location)
  }

  init(node: SyntaxNode) {
    self.init(nodes: [node])
  }

  init(nodes: [SyntaxNode]) {
    self.nodes = nodes
    self.range = nodes.map{$0.range}.union() ?? 0..<0
  }

  func disjoint(from other: TokenizerResult) -> TokenizerResult {
    return disjoint(from: other.range)
  }

  func disjoint(from range: Range<Int>) -> TokenizerResult {
    let nonOverlaping = self.nodes.filter{!$0.range.overlaps(range)}
    return TokenizerResult(nodes: nonOverlaping)
  }
}


public protocol TokenizerRepository: AnyObject {
  subscript(ref: GrammarRef) -> Tokenizer? { get }
}

