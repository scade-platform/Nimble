//
//  CodeEditorTextView.swift
//  CodeEditor
//
//  Created by Grigory Markin on 08.07.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import CodeEditor

extension CodeEditorTextView {
  
  public func apply(theme: Theme) {    
    self.selectedTextAttributes = [.backgroundColor: theme.general.selection]
    self.lineHighLightColor = theme.general.lineHighlight
    self.insertionPointColor = theme.general.caret
    
    if let textStorage = self.textStorage {
      for layoutManager in textStorage.layoutManagers {
        //layoutManager.firstTextView?.font = theme.font
        layoutManager.firstTextView?.textColor = theme.general.foreground
      }
    }
    
    lineNumberView?.needsDisplay = true
  }
}


