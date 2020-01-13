//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor


class CodeEditorView: NSViewController {
  var diagnostics: [SourceCodeDiagnostic] = []
  var diagnosticsUpdateTimer: DispatchSourceTimer? = nil
  
  weak var document: CodeEditorDocument? = nil {
    didSet {
      loadContent()
    }
  }
  
  @IBOutlet
  weak var textView: CodeEditorTextView?
  
  private weak var highlightProgress: Progress? = nil
  
    
  override func viewDidLoad() {
    super.viewDidLoad()
    textView?.delegate = self
    ColorThemeManager.shared.observers.add(observer: self)
    
    loadContent()
    
//    let diagnosticView = CodeEditorDiagnosticView()
//    self.textView?.addSubview(diagnosticView)
  }
  
  private func loadContent() {
    guard let textView = self.textView,
          let layoutManager = textView.layoutManager,
          let doc = document else { return }
    
    layoutManager.replaceTextStorage(doc.textStorage)
    doc.textStorage.delegate = self
    
    // Need to reapply whole coloring after replacing the textStorage
    applyTheme()
    
    ///TODO: read from settings
    if let font = NSFont.init(name: "SFMono-Medium", size: 12) {
      textView.font = font
    }
    
    highlightSyntax()
  }

  private func applyTheme(_ theme: ColorTheme? = nil) {
    guard let theme = theme ?? ColorThemeManager.shared.currentTheme else { return }
    textView?.backgroundColor = theme.global.background
    
    guard let textView = self.textView else { return }
    textView.apply(theme: theme)
  }
      
  private func showDiagnostics() {
    guard let textStorage = document?.textStorage else { return }
    
    let wholeRange = textStorage.string.nsRange
    
    // Clean previous diagnostics
    textStorage.layoutManagers.forEach {
      $0.removeTemporaryAttribute(.toolTip, forCharacterRange: wholeRange)
      $0.removeTemporaryAttribute(.underlineColor, forCharacterRange: wholeRange)
      $0.removeTemporaryAttribute(.underlineStyle, forCharacterRange: wholeRange)
    }
    
    // Show new diagnostics
    let style = NSNumber(value: NSUnderlineStyle.thick.rawValue)
        
    for d in diagnostics {
      let color = d.severity == .error ? NSColor.red : NSColor.yellow
      let range = textStorage.string.range(for: d.range)
      let nsRange = range.isEmpty ? NSRange(range.lowerBound..<range.upperBound + 1) : NSRange(range)
            
      textStorage.layoutManagers.forEach {
        $0.addTemporaryAttribute(.toolTip, value: d.message, forCharacterRange: nsRange)
        $0.addTemporaryAttribute(.underlineColor, value: color, forCharacterRange: nsRange)
        $0.addTemporaryAttribute(.underlineStyle, value: style, forCharacterRange: nsRange)
      }
    }
  }
  
  private func sheduleDiagnosticsUpdate() {
    if let timer = diagnosticsUpdateTimer {
      timer.cancel()
    }
    
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline:  .now() + 2.0) // 2 seconds delay
    timer.setEventHandler{[weak self] in
      self?.showDiagnostics()
    }
    timer.resume()
    
    diagnosticsUpdateTimer = timer
  }
  
  public func highlightSyntax() {
    if let doc = document {
      guard let syntaxParser = doc.syntaxParser else {
        doc.textStorage.layoutManagers.forEach {
          $0.removeTemporaryAttribute(.foregroundColor, forCharacterRange: doc.textStorage.range)
        }
        return
      }
      highlightProgress = syntaxParser.highlightAll()
    }
  }
}


// MARK: ColorThemeObserver

extension CodeEditorView: ColorThemeObserver {
  func colorThemeDidChanged(_ theme: ColorTheme) {
    self.applyTheme(theme)
    highlightSyntax()
  }
}


// MARK: WorkbenchEditor

extension CodeEditorView: WorkbenchEditor {
  var editorMenu: NSMenu? {
    CodeEditorMenu.shared.codeEditor = self
    return CodeEditorMenu.shared.nsMenu
  }
  
  func focus() -> Bool {
    return view.window?.makeFirstResponder(textView) ?? false
  }
    
  func publish(diagnostics: [Diagnostic]) {
    self.diagnostics = diagnostics.compactMap { return $0 as? SourceCodeDiagnostic }
    sheduleDiagnosticsUpdate()
  }
}


// MARK: NSTextStorageDelegate

extension CodeEditorView: NSTextStorageDelegate {
  override func textStorageDidProcessEditing(_ notification: Notification) {
    guard let doc = document,
          let textStorage = notification.object as? NSTextStorage,
              textStorage.editedMask.contains(.editedCharacters) else { return }
        
    doc.updateChangeCount(.changeDone)
    
    // Update highlighting
    guard let syntaxParser = doc.syntaxParser else { return }
    let range = textStorage.editedRange
    
    DispatchQueue.main.async { [weak self] in
      if let progress = self?.highlightProgress {
        progress.cancel()
        self?.highlightProgress = syntaxParser.highlightAll()
      } else {
        let _ = syntaxParser.highlight(around: range)
      }
    }
  }
}

// MARK: NSTextViewDelegate

extension CodeEditorView: NSTextViewDelegate {
  func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
    guard let doc = document else { return true }
    
    doc.observers.notify(as: SourceCodeDocumentObserver.self) {
      let range = affectedCharRange.lowerBound..<affectedCharRange.upperBound
      $0.textDidChange(document: doc, range: range, text: replacementString ?? "")
    }
    
    return true
  }
  
  func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
    return []
  }
}
