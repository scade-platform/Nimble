//
//  Range+Position.swift
//  LSPClient
//
//  Created by Danil Kristalev on 10.11.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import LanguageServerProtocol

public extension Range where Bound == Position {
  func isValid(for string: String) -> Bool {
    guard lowerBound.isValid(for: string),
          upperBound.isValid(for: string)
    else { return false }
    
    return true
  }
}

fileprivate extension Position {
  func isValid(for string: String) -> Bool {
    let startLineIndex: String.Index = string.lineRange(line: line).lowerBound
    return string.index(startLineIndex, offsetBy: utf16index, limitedBy: string.endIndex) != nil
  }
}
