//
//  CodeEditorLayoutManager.swift
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
