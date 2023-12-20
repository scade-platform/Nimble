//
//  CodeEditorgTextView+Layout.swift
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

import Cocoa

extension CodeEditorTextView {
  
  func boundingRect(for range: NSRange) -> NSRect? {
    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer else {
      return nil
    }
      
    let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
    let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    
    let textViewCoordinatesRect = NSOffsetRect(boundingRect, textContainerOrigin.x, textContainerOrigin.y)
    
    return textViewCoordinatesRect
  }
  
  func boundingRect(for range: Range<String.Index>) -> NSRect? {
    let nsRange = NSRange(range, in: self.string)
    return boundingRect(for: nsRange)
  }
}

