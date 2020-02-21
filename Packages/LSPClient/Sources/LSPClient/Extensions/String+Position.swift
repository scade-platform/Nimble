//
//  String+Position.swift
//  LSPClient
//
//  Created by Grigory Markin on 12.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

public extension String {
  func index(at pos: Position) -> String.Index {
    return utf16.index(lineRange(line: pos.line).lowerBound, offsetBy: pos.utf16index)
  }
  
  func range(for posRange: Range<Position>) -> Range<String.Index> {
    return index(at: posRange.lowerBound)..<index(at: posRange.upperBound)
  }

      
  func position(at index: Index) -> Position {
    let line = lineNumber(at: index)
    let range = lineRange(at: index)
    return Position(line: line, utf16index: utf16.distance(from: range.lowerBound, to: index))
  }
  
  func position(at offset: Int) -> Position {
    return position(at: index(at: offset))
  }
  
    
  func positionRange(for range: Range<Index>) -> Range<Position> {
    let lo = position(at: range.lowerBound)
    let hi = range.lowerBound < range.upperBound ? position(at: range.upperBound) : lo
    return lo..<hi
  }
  
  func positionRange(for range: Range<Int>) -> Range<Position> {
    let lo = position(at: range.lowerBound)
    let hi = range.lowerBound < range.upperBound ? position(at: range.upperBound) : lo
    return lo..<hi
  }
}

