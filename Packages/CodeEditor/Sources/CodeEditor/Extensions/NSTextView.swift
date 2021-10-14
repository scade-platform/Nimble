//
//  NSTextView.swift
//  CodeEditorCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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
import Foundation


extension NSTextView {
  var visibleRange: NSRange? {
      return range(for: visibleRect, withoutAdditionalLayout: true)
  }
      
  func range(for rect: NSRect, withoutAdditionalLayout: Bool = false) -> NSRange? {
    guard
      let layoutManager = self.layoutManager,
      let textContainer = self.textContainer else { return nil }
        
    let visibleRect = rect.offsetBy(dx: -textContainerOrigin.x, dy: -textContainerOrigin.x)
    let glyphRange = withoutAdditionalLayout
      ? layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: visibleRect, in: textContainer)
      : layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
      
    return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
  }
}
