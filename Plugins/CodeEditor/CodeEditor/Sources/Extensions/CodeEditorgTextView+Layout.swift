//
//  CodeEditorgTextView+Layout.swift
//  CodeEditor.plugin
//
//  Created by Danil Kristalev on 23.09.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa

extension CodeEditorTextView {
  
  var visibleRange: NSRange? {
    guard
        let layoutManager = self.layoutManager,
        let textContainer = self.textContainer
        else { return nil }
    
    let visibleRect = self.visibleRect
    let glyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: visibleRect, in: textContainer)
    return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
  }
  
  
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

