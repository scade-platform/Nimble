//
//  Parser.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 11.07.19.
//

import AppKit

public final class SyntaxParser {
  private let textStorage: NSTextStorage
  private let grammar: LanguageGrammar
  
  public init (textStorage: NSTextStorage, grammar: LanguageGrammar) {
    self.textStorage = textStorage
    self.grammar = grammar
  }
  
  public func highlightAll() {
    guard let tokenizer = grammar.tokenizer else { return }
    
    let str = String(utf8String: textStorage.string.cString(using: .utf8)!)!
    
    let t1 = mach_absolute_time()
    let res = tokenizer.tokenize(str)
    let t2 = mach_absolute_time()
    
    if let res = res {
      apply(res.nodes, in: res.range, for: str)
      
      for t in res.nodes {
        print("\(t)")
      }
      
      print("Tokenize time: \( Double(t2 - t1) * 1E-9)")
    }
    
  }
  
  private func apply(_ nodes: [SyntaxNode], `in` range: Range<Int>, for str: String) {
    let theme = ColorThemeManager.shared.currentTheme
    for layoutManager in self.textStorage.layoutManagers {
      layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: NSRange(range))
      nodes.visit {
        if let scope = $0, let setting = theme?.setting(for: scope), let color = setting.foreground {
          let range = NSRange(str.chars(utf8: $1))
          layoutManager.addTemporaryAttribute(.foregroundColor, value: color, forCharacterRange: range)
        }
      }
    }
  }
  
}
