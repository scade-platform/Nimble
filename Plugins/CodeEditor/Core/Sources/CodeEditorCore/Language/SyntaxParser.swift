//
//  Parser.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 11.07.19.
//

import AppKit
import NimbleCore

public final class SyntaxParser {
  private let grammar: LanguageGrammar
  
  private let textStorage: NSTextStorage
    
  private lazy var syntaxParseOperationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "com.nimble.codeeditor.core.syntaxParseOperationQueue"
    return queue
  }()
  
  
  public init (textStorage: NSTextStorage, grammar: LanguageGrammar) {
    self.grammar = grammar
    self.textStorage = textStorage
  }
  
    
  public func highlightAll() {
    highlight(str: textStorage.string, in: textStorage.string.range)
  }
  
  public func highlight(around range: Range<String.Index>) -> Void {
    //TODO: compute range and highlight
  }
  
  
  private func highlight(str: String, in range: Range<String.Index>) -> Void {
    guard !range.isEmpty else { return }
    
    guard let op = SyntaxParseOperation(grammar, str: str, range: range) else {return }
    op.qualityOfService = .userInitiated
    
    let modified = Atomic(false)
    weak var modificationObserver: NSObjectProtocol?
    
    modificationObserver = NotificationCenter.default.addObserver(forName: NSTextStorage.didProcessEditingNotification,
                                                                  object: self.textStorage, queue: nil)
    { [weak op] (note) in
        guard (note.object as! NSTextStorage).editedMask.contains(.editedCharacters) else { return }
        
        modified.modify { $0 = true }
        op?.cancel()
                                                                          
        if let observer = modificationObserver {
          NotificationCenter.default.removeObserver(observer)
        }
    }
    
    op.completionBlock = { [weak self, weak op] in
      func cleanup () {
        if let observer = modificationObserver {
          NotificationCenter.default.removeObserver(observer)
        }
      }
      
      guard let op = op, !op.isCancelled, let res = op.result else {
        cleanup()
        return
      }
      
      DispatchQueue.main.async {
        defer {
          cleanup()
        }
        guard !modified.value else { return }
        // store nodes
        self?.applyColoring(res.nodes, in: res.range, for: str)
      }
    }
    
    syntaxParseOperationQueue.addOperation(op)
  }
  
  
  private func applyColoring(_ nodes: [SyntaxNode], `in` range: Range<Int>, for str: String) {
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



class SyntaxParseOperation: Operation {
  let str: String
  let range: Range<String.Index>
  
  let tokenizer: Tokenizer
  
  var result: TokenizerResult? = nil
  
  init?(_ grammar: LanguageGrammar, str: String, range: Range<String.Index>) {
    guard let tokenizer = grammar.tokenizer else { return nil }
    self.tokenizer = tokenizer
    
    self.str = String(utf8String: str.cString(using: .utf8)!)!
    self.range = range
  }
  
  override func main () {
    if isCancelled {
        return
    }
    
    result = parse()
  }
  
  func parse() -> TokenizerResult? {
    let t1 = mach_absolute_time()
    let res = tokenizer.tokenize(str)
    let t2 = mach_absolute_time()
        
//    for t in res?.nodes ?? [] {
//      print("\(t)")
//    }
    print("Tokenize time: \( Double(t2 - t1) * 1E-9)")
    
    return res
  }
  
}
