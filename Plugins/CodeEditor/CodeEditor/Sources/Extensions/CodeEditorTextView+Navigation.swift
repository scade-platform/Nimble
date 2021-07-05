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

}


//MARK: - Navigation event

extension NSEvent {
  
  var leftArrowKeyCode: Int {
    return 123
  }
  
  var rightArrowKeyCode: Int {
    return 124
  }
  
  var downArrowKeyCode: Int {
    return 125
  }
  
  var upArrowKeyCode: Int {
    return 126
  }
  
  var isNavigation: Bool {
    //TODO: Use user bindings not hard code arrows
    guard type == .keyDown, keyCode >= leftArrowKeyCode && keyCode <= upArrowKeyCode else {
      return false
    }
    return true
  }
}
