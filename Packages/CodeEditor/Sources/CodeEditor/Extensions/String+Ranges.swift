//
//  String+Ranges.swift
//  CodeEditorCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

import Foundation

public extension String {
  var range: Range<Index> {
    return startIndex..<endIndex
  }
  
  var nsRange: NSRange {
    return  NSRange(location: 0, length: (self as NSString).length)
  }
  
  var numberOfLines: Int {
    return self.lineNumber(at: self.index(before: self.endIndex))
  }
  
  subscript(value: Int) -> Character {
    return self[index(at: value)]
  }
    
  subscript(value: Range<Int>) -> Substring {
    return self[self.index(at: value.lowerBound)..<self.index(at: value.upperBound)]
  }
  
  subscript(range: NSRange) -> Substring? {
    guard let range = Range(range, in: self) else { return nil }
    return self[range]
  }
  
  func index(at offset: Int) -> Index {
    return index(startIndex, offsetBy: offset)
  }
  
  func offset(at index: Index) -> Int {
    return distance(from: startIndex, to: index)
  }
  
  func range(for range: Range<Index>) -> Range<Int> {
    return offset(at: range.lowerBound)..<offset(at: range.upperBound)
  }

  func lines(from range: Range<Index>) -> [Range<Index>] {
    var line = lineRange(at: range.lowerBound)
    var lines: [Range<Index>] = []

    while(line.lowerBound <= range.upperBound){
      lines.append(line)

      guard line.upperBound != self.endIndex else { break }
      line = lineRange(at: line.upperBound)
    }

    return lines
  }

  func linesRange(from range: Range<Index>) -> Range<Index> {
    let lines = self.lines(from: range)

    guard let lb = lines.first?.lowerBound,
          let ub = lines.last?.upperBound else { return startIndex..<endIndex }

    return lb..<ub
  }

  /// Line number at index (one-based)
  func lineNumber(at location: Int) -> Int {
    let nsRange = NSRange(location..<location)
    guard let range = Range(nsRange, in: self) else { return 1 }
    return lineNumber(at: range.lowerBound)
  }

  /// Line number at index (one-based).
  func lineNumber(at index: Index) -> Int {
    assert(index <= endIndex)
    
    var count = 1
    var cur = self.startIndex
    while cur < index {
      if CharacterSet.newlines.contains(unicodeScalars[cur]) {
        count += 1
      }
      cur = self.index(after: cur)
    }
    
    return count
  }
  
  func lineRange(at: Index) -> Range<Index> {
    return lineRange(for: at..<at)
  }

  /// Index range of the line at 'lineNumber' (one-based !!!).
  func lineRange(line lineNumber: Int) -> Range<Index> {
    var line = lineRange(at: startIndex)

    for _ in 0..<lineNumber - 1 {
      line = lineRange(at: line.upperBound)
    }
        
    return line
  }
  
  func lineRange(line lineNumber: Int) -> Range<Int> {
    let range: Range<Index> = self.lineRange(line: lineNumber)
    return self.offset(at: range.lowerBound)..<self.offset(at: range.upperBound)
  }

  
  func utf8(at offset: Int) -> Int {
    return utf8(at: self.index(at: offset))
  }
  
  func utf8(at offset: Index) -> Int {
    return utf8.offset(at: offset)
  }
  
  func utf8(`in` range: Range<Index>) -> Range<Int> {
    let from = utf8(at: range.lowerBound)
    let to = utf8(at: range.upperBound)
    return from..<to
  }
  
  func utf8(`in` range: Range<Int>) -> Range<Int> {
    let from = utf8(at: range.lowerBound)
    let to = utf8(at: range.upperBound)
    return from..<to
  }
  
  func chars(utf8 range: Range<Int>) -> Range<Int> {
    let from = offset(at: utf8.index(at: range.lowerBound))
    let to = offset(at: utf8.index(at: range.upperBound))
    return from..<to
  }
  
  
  
  func utf16(at offset: Int) -> Int {
    return utf16(at: self.index(at: offset))
  }
  
  func utf16(at offset: Index) -> Int {
    return utf16.offset(at: offset)
  }
  
  func chars(utf16 range: Range<Int>) -> Range<Int> {
    let from = offset(at: utf16.index(at: range.lowerBound))
    let to = offset(at: utf16.index(at: range.upperBound))
    return from..<to
  }
}

// MARK: - UTF-8

public extension String.UTF8View {
  subscript(value: Int) -> UTF8.CodeUnit {
    return self[self.index(at: value)]
  }
  
  subscript(value: Range<Int>) -> String.UTF8View.SubSequence {
    return self[self.index(at: value.lowerBound)..<self.index(at: value.upperBound)]
  }
  
  func index(at offset: Int) -> String.UTF8View.Index {
    return index(startIndex, offsetBy: offset)
  }
  
  func offset(at index: Index) -> Int {
    return distance(from: startIndex, to: index)
  }
  
  func lines(from range: Range<Int>) -> [Range<Int>] {
    var line = lineRange(at: range.lowerBound)
    var lines: [Range<Int>] = []
    
    while(line.lowerBound < range.upperBound){
      lines.append(line)
      line = lineRange(at: line.upperBound)
    }
    
    return lines
  }
  

  func lineRange(for range: Range<Int>) -> Range<Int> {
    return lineStart(for: range)..<lineEnd(for: range)
  }
  
  func lineRange(at pos: Int) -> Range<Int> {
    return lineRange(for: pos..<pos)
  }
  
  func lineStart(for range: Range<Int>) -> Int {
    assert(range.lowerBound >= 0, "The value exceeds the bounds of the receiver")
    
    var begin = range.lowerBound
    while(begin > 0 && begin < count) {
      if isLineEnd(at: begin) || isLineEnd(at: begin - 1) {
        break
      } else {
        begin -= 1
      }
    }
    
    return begin
  }
  
  func lineStart(at pos: Int) -> Int {
    return lineStart(for: pos..<pos)
  }
  
  
  func lineEnd(for range: Range<Int>) -> Int {
    assert(range.upperBound <= count, "The value exceeds the bounds of the receiver")
    
    var end = range.upperBound
    while(end >= 0 && end < count) {
      if isLineEnd(at: end) {
        end += 1
        break
      } else {
        end += 1
      }
    }
    
    return end
  }
  
  func lineEnd(at pos: Int) -> Int {
    return lineEnd(for: pos..<pos)
  }
  

  private func isLineEnd(at index: Int) -> Bool {
///TBD: Support all following delimiters
//     U+2028 Unicode Character 'LINE SEPARATOR'
//     U+2029 Unicode Character 'PARAGRAPH SEPARATOR'
//     \r\n 'CRLN'
    return CharacterSet.newlines.contains(UnicodeScalar(self[index]))
  }
}


// MARK: - UTF-16

public extension String.UTF16View {
  subscript(value: Int) -> UTF16.CodeUnit {
    return self[self.index(at: value)]
  }
  
  subscript(value: Range<Int>) -> String.UTF16View.SubSequence {
    return self[self.index(at: value.lowerBound)..<self.index(at: value.upperBound)]
  }
  
  func index(at offset: Int) -> String.UTF16View.Index {
    return index(startIndex, offsetBy: offset)
  }
  
  func offset(at index: Index) -> Int {
    return distance(from: startIndex, to: index)
  }
  
  func range(for nsRange: NSRange) -> Range<Index> {
    return index(at: nsRange.lowerBound)..<index(at: nsRange.upperBound)
  }

  func nsRange(for range: Range<Index>) -> NSRange {
    return NSRange(location: self.offset(at: range.lowerBound), length:
      self.distance(from: range.lowerBound, to: range.upperBound))
  }
}
