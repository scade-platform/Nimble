//
//  NSRegularExpression.swift
//  
//
//  Created by Danil Kristalev on 26.07.2021.
//

import Foundation

public extension NSRegularExpression {
  func firstMatch(in string: String) -> NSTextCheckingResult? {
    return self.firstMatch(in: string,  range: string.nsRange)
  }
  
  func hasMatch(in string: String) -> Bool {
    return firstMatch(in: string) != nil
  }
}

fileprivate extension String {
  var nsRange: NSRange {
    return NSRange(startIndex..., in: self)
  }
}
