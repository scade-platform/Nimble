//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor


class CodeEditorView: NSView {
  @IBOutlet
  weak var textView: CodeEditorTextView?
}

extension CodeEditorView: DocumentView {
  func focus() -> Bool {
    return window?.makeFirstResponder(textView) ?? false
  }
}


class CodeEditorController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate {
  weak var document: SourceCodeDocument? = nil {
    didSet {
      loadContent()
    }
  }
  
  @IBOutlet
  weak var textView: CodeEditorTextView?
  
  private weak var highlightProgress: Progress? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadContent()
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

  private func applyTheme() {
    guard let theme = ColorThemeManager.shared.currentTheme else { return }
    view.setValue(theme.global.background, forKey: "backgroundColor")
    
    guard let textView = self.textView else { return }
    textView.apply(theme: theme)
  }
  
  
  public func highlightSyntax() {
    highlightProgress = document?.syntaxParser?.highlightAll()
  }
  
  
  override func textStorageDidProcessEditing(_ notification: Notification) {
    guard
      let textStorage = notification.object as? NSTextStorage,
      textStorage.editedMask.contains(.editedCharacters)
      else { return }
    
    document?.updateChangeCount(.changeDone)
    
    guard let syntaxParser = document?.syntaxParser else { return }
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
    guard let completions = document?.delegates.first?.complete() else { return [] }
    return completions
  }
}
