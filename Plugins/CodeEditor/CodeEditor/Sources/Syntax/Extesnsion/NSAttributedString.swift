//
//  NSAttributedString.swift
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    /// whole range
    var range: NSRange {
        
        return NSRange(..<self.length)
    }
    
    
    /// concatenate attributed strings
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        result.append(lhs)
        result.append(rhs)
        
        return result.copy() as! NSAttributedString
    }
    
    
    /// concatenate attributed strings
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        
        let result = NSMutableAttributedString()
        result.append(lhs)
        result.append(rhs)
        
        lhs = result.copy() as! NSAttributedString
    }
    
}
