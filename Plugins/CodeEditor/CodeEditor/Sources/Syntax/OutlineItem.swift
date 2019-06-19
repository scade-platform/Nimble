//
//  OutlineItem.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import AppKit.NSFont

struct OutlineItem: Equatable {
    
    struct Style: OptionSet {
        
        let rawValue: Int
        
        static let bold      = Style(rawValue: 1 << 0)
        static let italic    = Style(rawValue: 1 << 1)
        static let underline = Style(rawValue: 1 << 2)
    }
    

    var title: String
    var range: NSRange
    var style: Style = []
    
    
    init(title: String, range: NSRange, style: Style = []) {
        
        self.title = title
        self.range = range
        self.style = style
    }
    
    
    var isSeparator: Bool {
        
        return self.title == .separator
    }
    
}


extension OutlineItem {
    
    func attributedTitle(for baseFont: NSFont, attributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        
        var font = baseFont
        var attributes = attributes
        
        if self.style.contains(.bold) {
            font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        }
        if self.style.contains(.italic) {
            font = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
        }
        if self.style.contains(.underline) {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        attributes[.font] = font
        
        return NSAttributedString(string: self.title, attributes: attributes)
    }
    
}


extension Array where Element == OutlineItem {
    
    func indexOfItem(for characterRange: NSRange, allowsSeparator: Bool = true) -> Index? {
        
        return self.lastIndex { $0.range.location <= characterRange.location && (allowsSeparator || !$0.isSeparator ) }
    }
    
}
