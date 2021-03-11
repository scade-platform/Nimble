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
  
  
  private func highlight(str: String, in range: NSRange) -> Progress? {
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
}



class SyntaxParseOperation: Operation, ProgressReporting {
  let string: String
  var offsets: Atomic<String.OffsetTable>
  
  let range: NSRange
  let tokenizer: Tokenizer
      
  var result: TokenizerResult? = nil
  
  let progress: Progress
  
  init?(_ grammar: LanguageGrammar, str: String, range: NSRange) {
    guard let tokenizer = grammar.tokenizer else { return nil }
    self.tokenizer = tokenizer
    
    self.string = String(utf8String: str.cString(using: .utf8)!)!
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
      guard let table = self?.string.createOffsetTable(from: UTF8.self, to: UTF16.self) else { return }
      $0 = table
    }
    result = parse()
    let _ = offsetsComputed.wait(timeout: .distantFuture)
  }
  
  func parse() -> TokenizerResult? {
//    let t1 = mach_absolute_time()
    let res = tokenizer.tokenize(string, in: range)

//    if let nodes = res?.nodes {
//      nodes.forEach {
//        print($0)
//      }
//    }

//    let t2 = mach_absolute_time()
        
//    for t in res?.nodes ?? [] {
//      print("\(t)")
//    }
//    print("Tokenize time: \( Double(t2 - t1) * 1E-9)")
    
    return res
  }
  
}
