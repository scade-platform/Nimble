//
//  NSRegularExpression+Additions.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    
    /// Returns an array of all the matches of the regular expression in the string.
    ///
    /// - Parameters:
    ///   - string: The string to search.
    ///   - options: The matching options to use.
    ///   - range: The range of the string to search.
    ///   - block: The block gives a chance to cancel during a long-running match operation.
    /// - Returns: An array of all the matches or an empty array if cancelled.
    func matches(in string: String, options: NSRegularExpression.MatchingOptions, range: NSRange, using block: (_ stop: inout Bool) -> Void) -> [NSTextCheckingResult] {
        
        var matches: [NSTextCheckingResult] = []
        self.enumerateMatches(in: string, options: options, range: range) { (match, flags, stopPointer) in
            var stop = false
            block(&stop)
            if stop {
                stopPointer.pointee = ObjCBool(stop)
                matches = []
                return
            }
            
            if let match = match {
                matches.append(match)
            }
        }
        
        return matches
    }
    
}
