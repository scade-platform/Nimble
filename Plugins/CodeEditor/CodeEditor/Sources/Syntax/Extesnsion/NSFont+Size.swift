//
//  NSFont+Size.swift
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit.NSFont
import CoreText

extension NSFont {
    
    /// width of SPACE character
    var spaceWidth: CGFloat {
        
        return self.advancement(character: " ").width
    }
    
    
    /// Calculate advancement of a character using CoreText.
    ///
    /// - Parameter character: Character to calculate advancement.
    /// - Returns: Advancement of passed-in character.
    private func advancement(character: Character) -> NSSize {
        
        let glyph = (self as CTFont).glyph(for: character)
        
        guard #available(macOS 10.13, *) else {
            return (self as CTFont).advance(for: glyph)
        }
        
        return self.advancement(forCGGlyph: glyph)
    }
    
}



extension CTFont {
    
    /// Create CGGlyph from a character.
    ///
    /// - Parameter character: A character to extract glyph.
    /// - Returns: A CGGlyph for passed-in character based on the receiver font.
    func glyph(for character: Character) -> CGGlyph {
        
        assert(String(character).utf16.count == 1)
        
        var glyph = CGGlyph()
        let uniChar: UniChar = String(character).utf16.first!
        CTFontGetGlyphsForCharacters(self, [uniChar], &glyph, 1)
        
        return glyph
    }
    
    
    /// Get advancement of a glyph.
    ///
    /// - Parameters:
    ///   - glyph: Glyph to calculate advancement.
    ///   - orientation: Drawing orientation.
    /// - Returns: Advancement of passed-in glyph.
    func advance(for glyph: CGGlyph, orientation: CTFontOrientation = .horizontal) -> CGSize {
        
        var advance: CGSize = .zero
        CTFontGetAdvancesForGlyphs(self, orientation, [glyph], &advance, 1)
        
        return advance
    }
    
}
