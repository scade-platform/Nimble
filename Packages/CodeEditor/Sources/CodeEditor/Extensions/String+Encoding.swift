//
//  String+Encoding.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 18.10.19.
//

import Foundation

extension String {
  struct OffsetTable {
    private let table: [(Int, Int)]
    
    static let empty = OffsetTable()
    
    init(_ table: [(Int, Int)] = []) {
      self.table = table
    }
    
    func at(_ byteOffset: Int) -> Int {
      //TODO: use binary search here
      for (i, r) in table.enumerated() {
        if byteOffset > r.0 && (i == table.count - 1 || byteOffset <= table[i + 1].0) {
          return byteOffset - r.1
        }
      }
      return byteOffset
    }
    
    func map(_ range: Range<Int>) -> Range<Int> {
      return at(range.lowerBound)..<at(range.upperBound)
    }
  }
  
  /// Creates a mapping table from byte index to UTF8 character index
  func createUTF8OffsetTable() -> OffsetTable {
    var offset: Int = 0
    var table: [(Int, Int)] = []
    for (i, s) in self.unicodeScalars.enumerated() {
      let cur = i + offset
      if s.value > 128 && s.value <= 2048 {
        offset += 1
        table.append((cur, offset))
      } else if s.value > 2048 && s.value <= 65536 {
        offset += 2
        table.append((cur, offset))
      } else if s.value > 65536 {
        offset += 3
        table.append((cur, offset))
      }
    }
    return OffsetTable(table)
  }
  
  /// Creates a mapping table from byte index to UTF16 character index
  func createUTF16OffsetTable() -> OffsetTable {
    var offset: Int = 0
    var table: [(Int, Int)] = []
    for (i, s) in self.unicodeScalars.enumerated() {
      let cur = i + offset
      if s.value > 128 && s.value <= 65536 {
        offset += 1
        table.append((cur, offset))
      } else if s.value > 65536 {
        offset += 2
        table.append((cur, offset))
      }
    }
    return OffsetTable(table)
  }
  
  
}
