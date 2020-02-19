//
//  StatusBarView.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 14.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit
import NimbleCore


class StatusBarView: NSViewController {
  weak var textView: CodeEditorTextView?
  
  @IBOutlet weak var syntaxMenuButton: NSPopUpButton!
  @IBOutlet weak var cursorPositionLabel: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    syntaxMenuButton.menu = CodeEditorSyntaxMenu.nsMenu
    syntaxMenuButton.select(CodeEditorSyntaxMenu.nsMenu.items.first {
      return CodeEditorSyntaxMenu.itemState($0) == .on
    })
    
    if let pos = textView?.selectedPosition {
      setCursorPosition(pos.line, pos.column)
    }
  }
  
  func setCursorPosition(_ line: Int, _ column: Int) {
    cursorPositionLabel.stringValue = "Ln \(line), Col \(column)"
  }
}


// MARK: - Editor Status Bar

class EditorStatusBar: NSView {
  override var intrinsicContentSize: NSSize {
    return frame.size
  }
}

extension EditorStatusBar: WorkbenchStatusBarItem { }


