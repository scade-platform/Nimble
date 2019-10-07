//
//  NSRange.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 20.09.19.
//

import Foundation

public extension NSRange {
  var isEmpty: Bool { return length == 0 }
}

public extension Range {
  func union(_ other: Range) -> Range {
    return lowerBound..<other.upperBound
  }
}
