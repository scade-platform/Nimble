//
//  String+Ranges.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 11.07.19.
//

import Foundation

public extension String {
  var range: Range<Index> {
    return startIndex..<endIndex
  }
  
  var nsRange: NSRange {
    return  NSRange(location: 0, length: (self as NSString).length)
  }
  
  subscript(value: Range<Int>) -> Substring {
    return self[self.index(at: value.lowerBound)..<self.index(at: value.upperBound)]
  }
  
  func index(at offset: Int) -> String.Index {
    return index(startIndex, offsetBy: offset)
  }
  
  func utf8(at offset: Int) -> Int {
    return utf8(at: self.index(at: offset))
  }
  
  func utf8(at offset: Index) -> Int {
    return self.utf8.distance(from: self.startIndex, to: offset)
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
    let from = distance(from: startIndex, to: utf8.index(at: range.lowerBound))
    let to = distance(from: startIndex, to: utf8.index(at: range.upperBound))
    return from..<to
  }
}

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
  
  ///TBD: Support all following delimiters
  /*
   U+000A Unicode Character 'LINE FEED (LF)' (\n)
   U+000D Unicode Character 'CARRIAGE RETURN (CR)' (\r)
   U+0085 Unicode Character 'NEXT LINE (NEL)'
   U+2028 Unicode Character 'LINE SEPARATOR'
   U+2029 Unicode Character 'PARAGRAPH SEPARATOR'
   \r\n, in that order (also known as CRLF)
  */
  
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
      if self[begin] == 10 || self[begin - 1] == 10 {
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
      if self[end] == 10 {
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
}
