//
//  CodeEditorTextView.swift
//  CodeEditor
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
import CodeEditor

extension CodeEditorTextView {
  
  public func apply(theme: Theme) {    
    self.selectedTextAttributes = [.backgroundColor: theme.general.selection]
    self.lineHighLightColor = theme.general.lineHighlight
    self.insertionPointColor = theme.general.caret
    self.backgroundColor = theme.general.background

    if let textStorage = self.textStorage {
      for layoutManager in textStorage.layoutManagers {
        //layoutManager.firstTextView?.font = theme.font
        layoutManager.firstTextView?.textColor = theme.general.foreground
      }
    }
    
    lineNumberView?.needsDisplay = true
  }
}


