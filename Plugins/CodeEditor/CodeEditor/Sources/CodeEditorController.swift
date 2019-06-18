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
    
    textView?.setUpLineNumberView()
    loadContent()
  }
  
  private func loadContent() {
    if let content = doc?.content {
      textView?.string =  content
    }
  }
}
