//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class CodeEditorController: NSViewController, NSTextViewDelegate {
  weak var doc: SourceCodeDocument? = nil {
    didSet {
      loadContent()
    }
  }
  
  @IBOutlet
  weak var textView: NSTextView? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    if let theme = ThemeManager.shared.theme {
        view.setValue(theme.background.color, forKey: "backgroundColor")
    }
    
    guard let textView = textView else {
        return
    }
    
    //subscribe to type text changes
    NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSText.didChangeNotification, object: textView)
    
    setupTextView(textView: textView)
    loadContent()
    }
    
  private func loadContent() {
    guard let textView = textView,
        let layoutManager = textView.layoutManager,
        let doc = doc else {
        return
    }
   
    //update textStorage of textView.layoutManager
    layoutManager.replaceTextStorage(doc.textStorage)
    
    //setup text color & font from Theme
    if let textStorage = textView.textStorage, let theme = ThemeManager.shared.theme  {
        for layoutManager in textStorage.layoutManagers {
            layoutManager.firstTextView?.font = theme.font
            layoutManager.firstTextView?.textColor = theme.text.color
        }
    }
    
    //highlight syntax
      _ = doc.syntaxParser.highlightAll()
    }

    func setupTextView(textView: NSTextView) {
        //setup line count
        textView.setUpLineNumberView()

        if let theme = ThemeManager.shared.theme {
            textView.applyTheme(theme: theme)
        }
    }
    
    @objc private func textDidChange(notification: NSNotification) {
        _ = doc?.syntaxParser.highlightAll()
    }

    public func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
        guard let completions = doc?.delegates.first?.complete() else { return [] }
        return completions
    }
 }
