//
//  LineNumberView.swift
//  CodeEditor
//
//  Created by Grigory Markin on 30.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa


final class LineNumberView: NSRulerView {
  
  private let lineFont: NSFont
  private let textFont: NSFont
  
  private var textView: NSTextView? {
    return clientView as? NSTextView
  }
  
  private var layoutManager: NSLayoutManager? {
    return textView?.layoutManager
  }
  
  init(textView: NSTextView) {
    // TODO: load this from themes
    self.lineFont = NSFont.init(name: "XcodeDigits", size: 12) ?? NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
    self.textFont = NSFont.init(name: "SFMono-Medium", size: 12) ?? NSFont.systemFont(ofSize: 12)
    
    super.init(scrollView: textView.enclosingScrollView, orientation: NSRulerView.Orientation.verticalRuler)
    
    self.clientView = textView
    self.ruleThickness = 40
    
    // Hide the NSBannerView that always draw a background (NSVisualView)
    // The view exists starting from Mojave
    for v in self.subviews {
      if v.className == "NSBannerView" {
        v.isHidden = true
        break
      }
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    NSColor.clear.setFill()
    dirtyRect.fill()
  
    self.drawHashMarksAndLabels(in: dirtyRect)
  }
  
  func drawLineNumber(_ lineNumberString: String, in lineRect: NSRect, selected: Bool = false) {
    //let scale = textView.scale
    
    let numberColor = selected ? NSColor.white : NSColor.gray
    
    let relativePoint = self.convert(NSZeroPoint, from: textView)
    let lineNumberAttributes: [NSAttributedString.Key : Any] =
      [.font: lineFont, .foregroundColor: numberColor]
    
    let attString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
    
    let x = 35 - attString.size().width
    let y = relativePoint.y + lineRect.origin.y + lineRect.height + self.textFont.descender
    let rect = NSMakeRect(x,y, lineRect.width, lineRect.height)
    
    attString.draw(with: rect)
  }
  
  override func drawHashMarksAndLabels(in rect: NSRect) {
    guard let textView = self.textView, let layoutManager = self.layoutManager else { return }
    
    let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
    let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
    
    let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
    // The line number for the first visible line
    var lineNumber = newLineRegex.numberOfMatches(in: textView.string, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1
    
    var glyphIndexForStringLine = visibleGlyphRange.location
    
    // Go through each line in the string.
    while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
      
      // Range of current line in the string.
      let characterRangeForStringLine = (textView.string as NSString).lineRange(
        for: NSMakeRange( layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), 0 )
      )
      let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)
      
      // Check whether the current line is selected
      let isStringLineInSelection = textView.selectedRanges
        .map { $0.rangeValue }
        .contains { $0.intersection(characterRangeForStringLine) != nil }
      
      var glyphIndexForGlyphLine = glyphIndexForStringLine
      var glyphLineCount = 0
      
      while ( glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) ) {
        
        // See if the current line in the string spread across
        // several lines of glyphs
        var effectiveRange = NSMakeRange(0, 0)
        
        // Range of current "line of glyphs". If a line is wrapped,
        // then it will have more than one "line of glyphs"
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
        
        if glyphLineCount > 0 {
          drawLineNumber("", in: lineRect)
        } else {
          drawLineNumber("\(lineNumber)", in: lineRect, selected: isStringLineInSelection)
        }
        
        // Move to next glyph line
        glyphLineCount += 1
        glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
      }
      
      glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
      lineNumber += 1
    }
    
    // Draw line number for the extra line at the end of the text
    if layoutManager.extraLineFragmentTextContainer != nil {
      drawLineNumber("\(lineNumber)", in: layoutManager.extraLineFragmentRect)
    }
    
  }
}
