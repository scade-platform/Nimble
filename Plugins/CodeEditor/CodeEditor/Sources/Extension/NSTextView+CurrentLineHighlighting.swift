//
//  NSTextView+CurrentLineHighlighting.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 20/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit

protocol CurrentLineHighlighting: NSTextView {
  
  var needsUpdateLineHighlight: Bool { get set }
  var lineHighLightRects: [NSRect] { get set }
  var lineHighLightColor: NSColor? { get }
}



extension CurrentLineHighlighting {
  
  // MARK: Public Methods
  
  /// draw current line highlight
  func drawCurrentLine(in dirtyRect: NSRect) {
    
    if needsUpdateLineHighlight {
      lineHighLightRects = calculateLineHighLightRects()
      needsUpdateLineHighlight = false
    }
    
    guard let color = lineHighLightColor else {
      return
    }
    
    NSGraphicsContext.saveGraphicsState()
    
    color.withAlphaComponent(0.3).setFill()
    for rect in lineHighLightRects where rect.intersects(dirtyRect) {
      rect.fill()
    }
    
    NSGraphicsContext.restoreGraphicsState()
  }
  
  
  
  // MARK: Private Methods
  
  /// Calculate highlight rects for all insertion points.
  /// - Note: do not highlight when selection is not empty
  /// - Returns: Rects for current line highlight.
  private func calculateLineHighLightRects() -> [NSRect] {
    
    if self.selectedRanges.map({$0.rangeValue}).contains(where: {$0.length > 0}) {
      return []
    }
    
    return rangesForUserTextChange?
      .map { $0.rangeValue }
      .map { (string as NSString).lineContentsRange(for: $0) }
      .unique
      .map { lineRect(for: $0) }
      ?? []
  }
  
  
  /// Return rect for the line that contains the given range.
  ///
  /// - Parameter range: The range to obtain line rect.
  /// - Returns: Line rect in view coordinate.
  private func lineRect(for range: NSRange) -> NSRect {
    
    guard
      let textContainer = textContainer,
      let rect = boundingRect(for: range)
      else { assertionFailure(); return .zero }
    
    return NSRect(x: 0,
                  y: rect.minY,
                  width: textContainer.size.width,
                  height: rect.height)
      .insetBy(dx: textContainer.lineFragmentPadding, dy: 0)
      .integral
  }
  
}
