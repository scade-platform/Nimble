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
    guard let extractor = grammar.tokenizer else { return }
            
    let _ = extractor.tokenize(textStorage.string, in: textStorage.string.nsRange)
  }
  
}
