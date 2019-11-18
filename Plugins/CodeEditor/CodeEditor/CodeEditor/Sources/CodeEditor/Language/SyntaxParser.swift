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
  private var syntaxCache: SyntaxNode? = nil
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
  
    
  public func highlightAll() -> Progress? {
    // Highlight possibly the largest visible part (screen frame) of the document synchronously
    let screenFrame = NSScreen.main!.frame
    guard let range = textStorage.layoutManagers.first?.firstTextView?.range(for: screenFrame) else { return nil }
            
    guard let op = SyntaxParseOperation(grammar,
                                        str: textStorage.string,
                                        range: range) else { return nil }
    op.main()
    
    guard let res = op.result else { return nil }
    applyResults(res, range: op.range, offsets: op.offsets.value)
        
    // Process the rest of the document asynchronously
    let restRange = NSRange(res.range.upperBound..<textStorage.string.nsRange.upperBound)
    return highlight(str: textStorage.string, in: restRange)
  }
  
  
  
  public func highlight(around range: NSRange) -> Progress? {
    var highlightRange = range
    
    if let cache = syntaxCache {
      let dirty = cache.search(in: range)
      if !dirty.isEmpty {
        let begin = cache.nodes[dirty.lowerBound]
        let end = cache.nodes[cache.nodes.index(before: dirty.upperBound)]
        highlightRange = NSRange(begin.range.lowerBound..<end.range.upperBound)
      }
    }
    
    return highlight(str: textStorage.string, in: highlightRange)
  }
  
  
  private func highlight(str: String, in range: NSRange) -> Progress? {
    guard !range.isEmpty else { return nil }
    
    guard let op = SyntaxParseOperation(grammar, str: str, range: range) else {return nil }
    op.qualityOfService = .userInitiated
    
    let modified = Atomic(false)
    weak var modificationObserver: NSObjectProtocol?
    
    modificationObserver = NotificationCenter.default.addObserver (
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
      
      guard let op = op, !op.isCancelled else {
        cleanup()
        return
      }
      
      DispatchQueue.main.async {
        defer {
          cleanup()
        }
        
        guard !modified.value else { return }
        self?.applyResults(op.result, range: op.range, offsets: op.offsets.value)
      }
    }
    
    syntaxParseOperationQueue.addOperation(op)
    return op.progress
  }
  
  
  private func applyResults(_ res: TokenizerResult?, range: NSRange, offsets: String.OffsetTable) {
    let resultRange = offsets.at(res?.range.lowerBound ?? 0)..<offsets.at(res?.range.upperBound ?? 0)
    let updateRange = !resultRange.isEmpty ? range.union(NSRange(resultRange)) : range
            
    // Clear coloring in the `range`
    textStorage.layoutManagers.forEach {
      $0.removeTemporaryAttribute(.foregroundColor, forCharacterRange: updateRange)
    }
    
    
    var nodes = res?.nodes ?? []
    let theme = ColorThemeManager.shared.currentTheme
    
    // Visit and color nodes transforming ranges w.r.t offsets
    nodes.visit { node in
      node.range = offsets.at(node.range.lowerBound)..<offsets.at(node.range.upperBound)
      if let scope = node.scope, let setting = theme?.setting(for: scope), let color = setting.foreground {
        textStorage.layoutManagers.forEach {
          $0.addTemporaryAttribute(.foregroundColor, value: color, forCharacterRange: NSRange(node.range))
        }
      }
    }
            
    // Cache nodes
    if syntaxCache == nil && !nodes.isEmpty {
      syntaxCache = SyntaxNode(scope: nil, range: resultRange, nodes: nodes)
    } else {
      syntaxCache?.replace(subrange: updateRange, with: nodes)
    }
    
    if let cache = syntaxCache {
//      print("------------------------------")
//      print(cache)
    }
    
  }
}



class SyntaxParseOperation: Operation, ProgressReporting {
  let str: String
  var offsets: Atomic<String.OffsetTable>
  
  let range: NSRange
  let tokenizer: Tokenizer
      
  var result: TokenizerResult? = nil
  
  let progress: Progress
  
  init?(_ grammar: LanguageGrammar, str: String, range: NSRange) {
    guard let tokenizer = grammar.tokenizer else { return nil }
    self.tokenizer = tokenizer
    
    self.str = String(utf8String: str.cString(using: .utf8)!)!
    self.offsets = Atomic<String.OffsetTable>(String.OffsetTable.empty)
            
    self.range = range
    // For now just use one unit for the whole operation
    self.progress = Progress(totalUnitCount: 1)
    
    super.init()
    
    self.progress.cancellationHandler = { [weak self] in
      self?.cancel()
    }
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
//    let t1 = mach_absolute_time()
    let res = tokenizer.tokenize(str, in: range)
//    let t2 = mach_absolute_time()
        
//    for t in res?.nodes ?? [] {
//      print("\(t)")
//    }
//    print("Tokenize time: \( Double(t2 - t1) * 1E-9)")
    
    return res
  }
  
}
