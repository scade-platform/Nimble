//
//  NSTextView+LineNumber.swift
//  CodeEditor
//
//  Created by Mark Goldin on 18/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import Foundation
import ObjectiveC

var LineNumberViewAssociatedKey: UInt8 = 0

extension NSTextView {
    
    var lineNumberView: LineNumberRulerView {
        get {
            return objc_getAssociatedObject(self, &LineNumberViewAssociatedKey) as! LineNumberRulerView
        }
        
        set {
            objc_setAssociatedObject(self, &LineNumberViewAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setUpLineNumberView() {
        if let scrollView = enclosingScrollView {
            lineNumberView = LineNumberRulerView(textView: self)
            
            scrollView.verticalRulerView = lineNumberView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
        }
        
        postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(frameDidChange), name: NSView.frameDidChangeNotification, object: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSText.didChangeNotification, object: self)
    }
    
    @objc private func frameDidChange(notification: NSNotification) {
        lineNumberView.needsDisplay = true
    }
    
    @objc private func textDidChange(notification: NSNotification) {
        lineNumberView.needsDisplay = true
    }
}

class LineNumberRulerView: NSRulerView {
    
    private let lineFont: NSFont
    
    init(textView: NSTextView) {
        lineFont = NSFont.init(name: "SFMono-Medium", size: 10.5) ?? NSFont.systemFont(ofSize: 10.5)
        
        super.init(scrollView: textView.enclosingScrollView!, orientation: NSRulerView.Orientation.verticalRuler)
        
        clientView = textView
        ruleThickness = 40
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        
        guard let textView = clientView as? NSTextView, let layoutManager = textView.layoutManager else {
            return
        }
        
        let relativePoint = convert(NSZeroPoint, from: textView)
        let lineNumberAttributes = [NSAttributedString.Key.font: lineFont, NSAttributedString.Key.foregroundColor: NSColor.gray] as [NSAttributedString.Key : Any]
        
        let drawLineNumber = { (lineNumberString: String, y: CGFloat) -> Void in
            let attString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
            let x = 35 - attString.size().width
            attString.draw(at: NSPoint(x: x, y: relativePoint.y + y + 8))
        }
        
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
                    drawLineNumber("", lineRect.minY)
                } else {
                    drawLineNumber("\(lineNumber)", lineRect.minY)
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
            drawLineNumber("\(lineNumber)", layoutManager.extraLineFragmentRect.minY)
        }
        
    }
}
