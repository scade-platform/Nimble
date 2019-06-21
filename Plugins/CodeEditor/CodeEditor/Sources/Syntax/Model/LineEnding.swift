//
//  LineEnding.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

enum LineEnding: Character {
    
    case lf = "\n"
    case cr = "\r"
    case crlf = "\r\n"
    case lineSeparator = "\u{2028}"
    case paragraphSeparator = "\u{2029}"
    
    static let basic: [LineEnding] = [.cr, .cr, .crlf]
    
    
    var string: String {
        
        return String(self.rawValue)
    }
    
    
    var name: String {
        
        switch self {
        case .lf:
            return "LF"
        case .cr:
            return "CR"
        case .crlf:
            return "CRLF"
        case .lineSeparator:
            return "LS"
        case .paragraphSeparator:
            return "PS"
        }
    }
    
    
    var localizedName: String {
        
        switch self {
        case .lf:
            return "macOS / Unix (LF)"
        case .cr:
            return "Classic Mac OS (CR)"
        case .crlf:
            return "Windows (CRLF)"
        case .lineSeparator:
            return "Unix Line Separator"
        case .paragraphSeparator:
            return "Unix Paragraph Separator"
        }
    }
    
    
    var length: Int {
        
        return self.rawValue.unicodeScalars.count
    }
    
}



// MARK: -

private extension LineEnding {
    
    static let characterSet = CharacterSet(charactersIn: "\n\r\u{2028}\u{2029}")
    static let regexPattern = "\\r\\n|[\\n\\r\\u2028\\u2029]"
}


extension StringProtocol where Self.Index == String.Index {
    
    /// The first line ending type.
    var detectedLineEnding: LineEnding? {
        
        // We don't use `CharacterSet.newlines` because it contains more characters than we need.
        guard
            let range = self.rangeOfCharacter(from: LineEnding.characterSet),
            let character = self[range].first  // Swift treats "\r\n" also as a single character.
            else { return nil }
        
        return LineEnding(rawValue: character)
    }
    
    
    /// Count characters in the receiver but except all kinds of line endings.
    var countExceptLineEnding: Int {
        
        // workarond for Swift 5.1 that removes BOM at the beginning (2019-05 Swift 5.1).
        if self.starts(with: "\u{FEFF}") {
            let startIndex = self.index(after: self.startIndex)
            return self[startIndex...].replacingOccurrences(of: LineEnding.regexPattern, with: "", options: .regularExpression).count + 1
        }
        
        return self.replacingOccurrences(of: LineEnding.regexPattern, with: "", options: .regularExpression).count
    }
    
    
    /// String replacing all kind of line ending characters in the the receiver with the desired line ending.
    ///
    /// - Parameter lineEnding: The line ending type to replace with.
    /// - Returns: String replacing line ending characers.
    func replacingLineEndings(with lineEnding: LineEnding) -> String {
        
        return self.replacingOccurrences(of: LineEnding.regexPattern, with: lineEnding.string, options: .regularExpression)
    }
    
    
    /// Convert passed-in range as if line endings are changed from `fromLineEnding` to `toLineEnding`
    /// by assuming the receiver has `fromLineEnding` regardless of actual ones if specified.
    ///
    /// - Important: Consider to avoid using this method in a frequent loop as it's relatively heavy.
    func convert(range: NSRange, from fromLineEnding: LineEnding? = nil, to toLineEnding: LineEnding) -> NSRange {
        
        guard let currentLineEnding = (fromLineEnding ?? self.detectedLineEnding) else { return range }
        
        let delta = toLineEnding.length - currentLineEnding.length
        
        guard delta != 0 else { return range }
        
        let string = self.replacingLineEndings(with: currentLineEnding)
        let regex = try! NSRegularExpression(pattern: LineEnding.regexPattern)
        let locationRange = NSRange(..<range.location)
        
        let locationDelta = delta * regex.numberOfMatches(in: string, range: locationRange)
        let lengthDelta = delta * regex.numberOfMatches(in: string, range: range)
        
        return NSRange(location: range.location + locationDelta, length: range.length + lengthDelta)
    }
    
}
