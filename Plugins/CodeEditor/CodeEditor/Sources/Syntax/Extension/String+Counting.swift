//
//  String+Counting.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

extension StringProtocol where Self.Index == String.Index {
    
    /// number of lines in the whole string ignoring the last new line character
    var numberOfLines: Int {
        
        return self.numberOfLines(includingLastLineEnding: false)
    }
    
    
    /// count the number of lines at the character index (1-based).
    func lineNumber(at index: Self.Index) -> Int {
        
        guard !self.isEmpty, index > self.startIndex else { return 1 }
        
        return self.numberOfLines(in: self.startIndex..<index, includingLastLineEnding: true)
    }
    
    
    /// count the number of lines in the range
    func numberOfLines(in range: Range<String.Index>? = nil, includingLastLineEnding: Bool) -> Int {
        
        let range = range ?? self.startIndex..<self.endIndex
        
        if self.isEmpty || range.isEmpty { return 0 }
        
        // workarond for the Swift 5 issue that removes BOM at the beginning (2019-05 Swift 5.0).
        guard self.first != "\u{FEFF}" || self.count > 16 else {
            let newlines = Set<Character>(["\n", "\r", "\r\n", "\u{0085}", "\u{2028}", "\u{2029}"])
            let count = self[range].count { newlines.contains($0) } + 1
            
            if !includingLastLineEnding,
                let last = self[range].last,
                newlines.contains(last) {
                return count - 1
            }
            return count
        }
        
        var count = 0
        self.enumerateSubstrings(in: range, options: [.byLines, .substringNotRequired]) { (_, _, _, _) in
            count += 1
        }
        
        if includingLastLineEnding,
            let last = self[range].unicodeScalars.last,
            CharacterSet.newlines.contains(last)
        {
            count += 1
        }
        
        return count
    }
    
}



// MARK: NSRange based

extension String {
    
    /// count the number of lines at the character index (1-based).
    func lineNumber(at location: Int) -> Int {
        
        guard !self.isEmpty, location > 0 else { return 1 }
        
        return self.numberOfLines(in: NSRange(..<location), includingLastLineEnding: true)
    }
    
    
    /// count the number of lines in the range
    func numberOfLines(in range: NSRange, includingLastLineEnding: Bool) -> Int {
        
        guard let characterRange = Range(range, in: self) else { return 0 }
        
        return self.numberOfLines(in: characterRange, includingLastLineEnding: includingLastLineEnding)
    }
    
}
