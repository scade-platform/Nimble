//
//  SyntaxParser.swift
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

// MARK: - SyntaxParser

public final class SyntaxParser {
  private let grammar: LanguageGrammar

  public init (grammar: LanguageGrammar) {
    self.grammar = grammar
    self.grammar.preload()
  }

  /*
  public func highlightAll() -> Progress? {
    // Highlight possibly the largest visible part (screen frame) of the document synchronously
    let screenFrame = NSScreen.main!.frame
    guard let range = textStorage.layoutManagers.first?.firstTextView?.range(for: screenFrame) else { return nil }
            
    guard let op = SyntaxParseOperation(grammar,
                                        str: textStorage.string,
                                        range: range) else { return nil }
    op.main()
    
    guard let res = op.result else { return nil }
    let offsets = op.offsets.value
    
    applyResults(res, range: op.range, offsets: offsets)
    
    let resRange = offsets.map(res.range)
    
    // Process the rest of the document asynchronously
    let restRange = NSRange(resRange.upperBound..<textStorage.string.nsRange.upperBound)
    return highlight(str: textStorage.string, in: restRange)
  }


  public func highlightAround(editedRange: NSRange, changeInLength delta: Int) -> Progress? {
    let dirtyRange = editedRange.lowerBound..<editedRange.upperBound - delta

    //print("Edited range: \(editedRange) Delta: \(delta)")

    guard let cache = syntaxCache else {
      return highlightAll()
    }

    let dirtyNodes = cache.search(in: dirtyRange)

    // Update cache
    var cacheNodes = syntaxCache?.nodes[..<dirtyNodes.lowerBound] ?? []
    syntaxCache?.nodes[dirtyNodes.upperBound...].forEach {
      var node = $0
      node.visit {
        guard let range = $0.range else { return }
        $0.range = range.lowerBound + delta..<range.upperBound + delta
      }
      cacheNodes.append(node)
    }

    syntaxCache = SyntaxNode(scope: syntaxCache?.scope, nodes: cacheNodes)

    // Highlight within dirty nodes
    if !dirtyNodes.isEmpty {
      guard let lb = cache.nodes[dirtyNodes.lowerBound].range?.lowerBound,
            let ub = cache.nodes[cache.nodes.index(before: dirtyNodes.upperBound)].range?.upperBound else { return nil }

      let range = NSRange(min(lb, editedRange.lowerBound)..<max(ub, editedRange.upperBound))
      //print("Dirty range: \(range)")
      return highlight(str: textStorage.string, in: range)
    }

    return highlight(str: textStorage.string, in: editedRange)
  }
  */

  /*
  private func applyResults(_ res: TokenizerResult?, range: NSRange, offsets: String.OffsetTable) {
    let resultRange = offsets.at(res?.range.lowerBound ?? 0)..<offsets.at(res?.range.upperBound ?? 0)
    let updateRange = !resultRange.isEmpty ? range.union(NSRange(resultRange)) : range
            
    // Clear coloring in the `range`
    textStorage.layoutManagers.forEach {
      $0.removeTemporaryAttribute(.foregroundColor, forCharacterRange: updateRange)
    }
    
    
    var nodes = res?.nodes ?? []
    let theme = ThemeManager.shared.currentTheme
    
    // Visit and color nodes transforming ranges w.r.t offsets
    nodes.visit { node in
      guard var range = node.range else { return }
      // Store mapped range w.r.t. offsets
      range = offsets.map(range)
      node.range = range

      let nodeRange = NSRange(range)
      if let scope = node.scope, let setting = theme?.setting(for: scope) {

        if let color = setting.foreground {
          textStorage.layoutManagers.forEach {
            $0.addTemporaryAttribute(.foregroundColor, value: color, forCharacterRange: nodeRange)
          }
        }

        if let fontStyle = setting.fontStyle, !fontStyle.isEmpty,
           let themeFont = theme?.general.font {

          let font = NSFontManager.shared.convert(themeFont, toHaveTrait: fontStyle)
          textStorage.addAttribute(.font, value: font, range: nodeRange)
        }
      }
    }
            
    // Cache nodes
    if syntaxCache == nil && !nodes.isEmpty {
      syntaxCache = SyntaxNode(scope: nil, range: resultRange, nodes: nodes)
    } else {
      syntaxCache?.replace(subrange: updateRange, with: nodes)
    }
  }

   */
}

// MARK: - + SyntaxParser + LanguageService

extension SyntaxParser: LanguageService {
  public var supportedFeatures: [LanguageServiceFeature] { [.tokenize] }

  public func tokenize(doc: SourceCodeDocument, range: Range<Int>) -> [SyntaxNode] {    
    return grammar.tokenizer?.tokenize(doc.text, in: range)?.nodes ?? []
  }
}
