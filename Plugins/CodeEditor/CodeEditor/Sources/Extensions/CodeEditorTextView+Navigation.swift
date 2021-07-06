//
//  CodeEditorTextView+Navigation.swift
//  CodeEditor.plugin
//
//  Created by Danil Kristalev on 05.07.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor

extension CodeEditorTextView {

  //MARK: - Navigation event
  
  //TODO: User key bindings
  
  //cmd + left
  override func moveToBeginningOfLine(_ sender: Any?) {
    guard let firstCharIndex = currentLineSubstring.firstCharIndex, firstCharIndex < selectedIndex else {
      super.moveToBeginningOfLine(sender)
      return
    }
    
    let nsRange = NSRange(firstCharIndex ..< firstCharIndex, in: string)
    setSelectedRange(nsRange)
  }
  
  //cmd + backspace
  override func deleteToBeginningOfLine(_ sender: Any?) {
    guard let firstCharIndex = currentLineSubstring.firstCharIndex, firstCharIndex < selectedIndex else {
      super.deleteToBeginningOfLine(sender)
      return
    }
    
    let nsRange = NSRange(firstCharIndex ..< selectedIndex, in: string)
    insertText("", replacementRange: nsRange)
  }
    
  //option + left
  override func moveWordLeft(_ sender: Any?) {
    super.moveWordLeft(sender)
  }
  
  //option + right
  override func moveWordRight(_ sender: Any?) {
    super.moveWordRight(sender)
  }
}

fileprivate extension CodeEditorTextView {
  var currentLineSubstring: Substring {
    string[string.lineRange(at: selectedIndex)]
  }
}

fileprivate extension Substring {
  var firstCharIndex: String.Index? {
    firstIndex(where: { !$0.isWhitespace })
  }
}

