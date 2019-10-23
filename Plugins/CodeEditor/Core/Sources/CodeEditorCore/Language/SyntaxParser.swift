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
    
    self.grammar.preload()
  }
  
    
  public func highlightAll() {
    // Highlight possibly the largest visible part (screen frame) of the document synchronously
    let screenFrame = NSScreen.main!.frame
    guard let range = textStorage.layoutManagers.first?.firstTextView?.range(for: screenFrame) else { return }
            
    guard let op = SyntaxParseOperation(grammar,
                                        str: textStorage.string,
                                        range: range) else {return }
    
    op.main()
    guard let res = op.result else { return }
    
    applyColoring(res.nodes, in: res.range, for: textStorage.string, offsets: op.offsets.value)
    
    // Color the rest of the document asynchronously
    let restRange = NSRange(res.range.upperBound..<textStorage.string.nsRange.upperBound)
    highlight(str: textStorage.string, in: restRange)
  }
  
  
  
  public func highlight(around range: NSRange) -> Void {
    ///TODO: compute range and highlight
  }
  
  
  private func highlight(str: String, in range: NSRange) -> Void {
    guard !range.isEmpty else { return }
    
    guard let op = SyntaxParseOperation(grammar, str: str, range: range) else {return }
    op.qualityOfService = .userInitiated
    
    let modified = Atomic(false)
    weak var modificationObserver: NSObjectProtocol?
    
    modificationObserver = NotificationCenter.default.addObserver(
      forName: NSTextStorage.didProcessEditingNotification,
      object: self.textStorage, queue: nil) { [weak op] (note) in
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
        self?.applyColoring(res.nodes, in: res.range, for: str, offsets: op.offsets.value)
      }
      
      ///TODO: Store results
    }
    
    syntaxParseOperationQueue.addOperation(op)
  }
  
  
  
  private func applyColoring(_ nodes: [SyntaxNode], `in` range: Range<Int>,
                             for str: String, offsets: String.OffsetTable = String.OffsetTable.empty) {
            
    let theme = ColorThemeManager.shared.currentTheme
    for layoutManager in self.textStorage.layoutManagers {
      layoutManager.removeTemporaryAttribute(.foregroundColor, forCharacterRange: NSRange(range))
      
      nodes.visit {
        if let scope = $0, let setting = theme?.setting(for: scope), let color = setting.foreground {
          let range = NSRange(offsets.at($1.lowerBound)..<offsets.at($1.upperBound))
          layoutManager.addTemporaryAttribute(.foregroundColor, value: color, forCharacterRange: range)
        }
      }
    }
  }
  
}



class SyntaxParseOperation: Operation {
  let str: String
  var offsets: Atomic<String.OffsetTable>
  
  let range: NSRange
  let tokenizer: Tokenizer
  
  var result: TokenizerResult? = nil
  
  init?(_ grammar: LanguageGrammar, str: String, range: NSRange) {
    guard let tokenizer = grammar.tokenizer else { return nil }
    self.tokenizer = tokenizer
    self.str = String(utf8String: str.cString(using: .utf8)!)!
    self.offsets = Atomic<String.OffsetTable>(String.OffsetTable.empty)
    self.range = range
  }
  
  override func main () {
    if isCancelled {
        return
    }
    
    let offsetsComputed = DispatchSemaphore(value: 0)
    offsets.asyncModify { [weak self] in
      defer {
        offsetsComputed.signal()
      }
      guard let table = self?.str.createUTF8OffsetTable() else { return }
      $0 = table
    }
    result = parse()
    let _ = offsetsComputed.wait(timeout: .distantFuture)
  }
  
  func parse() -> TokenizerResult? {
    let t1 = mach_absolute_time()
    let res = tokenizer.tokenize(str, in: range)
    let t2 = mach_absolute_time()
        
//    for t in res?.nodes ?? [] {
//      print("\(t)")
//    }
    print("Tokenize time: \( Double(t2 - t1) * 1E-9)")
    
    return res
  }
  
}
