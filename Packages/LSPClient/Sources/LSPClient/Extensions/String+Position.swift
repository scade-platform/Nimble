//
//  String+Position.swift
//  LSPClient
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
import LanguageServerProtocol

public extension String {
  func index(at pos: Position) -> String.Index? {
    // LSP position line is zero-based
    let lineRange: Range<String.Index> = lineRange(line: pos.line + 1)

    let startLineIndex = lineRange.lowerBound
    let endLineIndex = lineRange.upperBound

    return index(startLineIndex, offsetBy: pos.utf16index, limitedBy: endLineIndex)
  }
  
  func range(for posRange: Range<Position>) -> Range<String.Index>? {
    guard let begin = index(at: posRange.lowerBound),
          let end = index(at: posRange.upperBound) else { return nil }
    return begin..<end
  }

      
  func position(at index: Index) -> Position {
    let line = lineNumber(at: index)
    let range = lineRange(at: index)
    return Position(line: line - 1, utf16index: utf16.distance(from: range.lowerBound, to: index))
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

