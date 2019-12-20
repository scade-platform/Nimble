//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor


class CodeEditorView: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {
  var diagnostics: [(NSRange, Diagnostic)] = []
  
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
    
  
  override func textStorageDidProcessEditing(_ notification: Notification) {
    guard let doc = document,
          let textStorage = notification.object as? NSTextStorage,
              textStorage.editedMask.contains(.editedCharacters) else { return }
        
    doc.updateChangeCount(.changeDone)
    
    doc.observers.notify(as: SourceCodeDocumentObserver.self) {
      let range = textStorage.editedRange.lowerBound..<textStorage.editedRange.upperBound
      $0.textDidChange(document: doc, range: range, lengthDelta: textStorage.changeInLength)
    }
    
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

  
  func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
    return []
  }
}


extension CodeEditorView: ColorThemeObserver {
  func colorThemeDidChanged(_ theme: ColorTheme) {
    self.applyTheme(theme)
    highlightSyntax()
  }
}

extension CodeEditorView: WorkbenchEditor {
  var editorMenu: NSMenu? {
    CodeEditorMenu.shared.codeEditor = self
    return CodeEditorMenu.shared.nsMenu
  }
  
  func focus() -> Bool {
    return view.window?.makeFirstResponder(textView) ?? false
  }
    
  func publish(diagnostics: [Diagnostic]) {
    guard let textStorage = document?.textStorage else { return }
    
    for (range, _) in self.diagnostics {
      textStorage.layoutManagers.forEach {
        $0.removeTemporaryAttribute(.toolTip, forCharacterRange: range)
        $0.removeTemporaryAttribute(.underlineColor, forCharacterRange: range)
        $0.removeTemporaryAttribute(.underlineStyle, forCharacterRange: range)
      }
    }
            
    let diagnostics = diagnostics.compactMap { return $0 as? SourceCodeDiagnostic }
        
    let style = NSNumber(value: NSUnderlineStyle.single.rawValue)
    
    for d in diagnostics {
      let color = d.severity == .error ? NSColor.red : NSColor.yellow
      let range = textStorage.string.range(for: d.range)
      let nsRange = range.isEmpty ? NSRange(range.lowerBound..<range.upperBound + 1) : NSRange(range)
      
      textStorage.layoutManagers.forEach {
        $0.addTemporaryAttribute(.toolTip, value: d.message, forCharacterRange: nsRange)
        $0.addTemporaryAttribute(.underlineColor, value: color, forCharacterRange: nsRange)
        $0.addTemporaryAttribute(.underlineStyle, value: style, forCharacterRange: nsRange)
        
      }
      
      self.diagnostics.append((nsRange, d))
    }
  }
}

