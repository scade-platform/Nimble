//
//  StatusBarView.swift
//  CodeEditor.plugin
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import NimbleCore


class StatusBarView: NSViewController {
  weak var textView: CodeEditorTextView?
  
  @IBOutlet weak var syntaxMenuButton: NSPopUpButton?
  @IBOutlet weak var cursorPositionLabel: NSTextField?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    syntaxMenuButton?.menu = CodeEditorSyntaxMenu.nsMenu
    updateSelectedSyntax()
    
    if let pos = textView?.selectedPosition {
      setCursorPosition(pos.line, pos.column)
    }
  }
  
  func setCursorPosition(_ line: Int, _ column: Int) {
    guard let label = cursorPositionLabel else {
      return
    }
    label.stringValue = "Ln \(line + 1), Col \(column + 1)"
  }

  func updateSelectedSyntax() {
    syntaxMenuButton?.select(CodeEditorSyntaxMenu.nsMenu.items.first {
      return CodeEditorSyntaxMenu.itemState($0) == .on
    })
  }
}


// MARK: - Editor Status Bar

class EditorStatusBar: NSView {
  override var intrinsicContentSize: NSSize {
    return frame.size
  }
}

extension EditorStatusBar: WorkbenchStatusBarItem { }


