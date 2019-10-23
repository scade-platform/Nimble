//
//  NSTextView.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 17.10.19.
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
