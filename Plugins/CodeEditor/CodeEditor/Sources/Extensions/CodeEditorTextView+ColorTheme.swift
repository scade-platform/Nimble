//
//  CodeEditorTextView.swift
//  CodeEditor
//
//  Created by Grigory Markin on 08.07.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import CodeEditorCore

extension CodeEditorTextView {
  
  public func apply(theme: ColorTheme) {
    self.selectedTextAttributes = [.backgroundColor: theme.global.selection]
    self.lineHighLightColor = theme.global.lineHighlight
    
    if let textStorage = self.textStorage {
      for layoutManager in textStorage.layoutManagers {
        //layoutManager.firstTextView?.font = theme.font
        layoutManager.firstTextView?.textColor = theme.global.foreground
      }
    }
  }
  
}


