//
//  CodeEditorLayoutManager.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 06.01.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

final class CodeEditorLayoutManager: NSLayoutManager {

  override func drawUnderline(forGlyphRange glyphRange: NSRange, underlineType underlineVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: NSRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: NSPoint) {
    
    guard let container = textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) else { return }
    let rect = boundingRect(forGlyphRange: glyphRange, in: container)
    
    let offsetRect = rect.offsetBy(dx: containerOrigin.x, dy: containerOrigin.y)
    drawUnderline(under: offsetRect)
  }
  
  func drawUnderline(under rect: CGRect) {
    let path = NSBezierPath()
    
    path.lineWidth = 2
    //path.lineCapStyle = .round
    //path.setLineDash([0, 3.75], count: 2, phase: 0)
    
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.line(to: CGPoint(x: rect.maxX, y: rect.maxY))
    
    path.stroke()
  }
}
