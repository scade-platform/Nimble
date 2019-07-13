//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import CodeEditorCore

class CodeEditorController: NSViewController, NSTextViewDelegate {
  weak var doc: SourceCodeDocument? = nil {
    didSet {
      loadContent()
    }
  }
  
  @IBOutlet
  weak var textView: CodeEditorTextView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSText.didChangeNotification, object: textView)
    
    loadContent()
  }
  
  private func loadContent() {
    guard let textView = self.textView,
          let layoutManager = textView.layoutManager,
          let doc = doc else { return }
    
    layoutManager.replaceTextStorage(doc.textStorage)
    
    // Need to reapply whole coloring after replacing the textStorage
    applyTheme()
    
    // Highlight syntax
    doc.syntaxParser?.highlightAll()
  }

  private func applyTheme() {
    guard let theme = ColorThemeManager.shared.currentTheme else { return }
    view.setValue(theme.global.background, forKey: "backgroundColor")
    
    guard let textView = self.textView else { return }
    textView.apply(theme: theme)
  }
  
  @objc private func textDidChange(notification: NSNotification) {
    //_ = doc?.syntaxParser.highlightAll()
  }
  
  public func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
    guard let completions = doc?.delegates.first?.complete() else { return [] }
    return completions
  }
}
