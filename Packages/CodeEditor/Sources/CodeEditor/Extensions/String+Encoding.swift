//
//  String+Encoding.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 18.10.19.
//

import Foundation

extension String {
  struct OffsetTable {
    static let empty = OffsetTable()
    
    private let table: [(Int, Int)]
            
    init(_ table: [(Int, Int)] = []) {
      self.table = table
    }
    
    func at(_ byteOffset: Int) -> Int {
      ///TODO: use binary search here
      for (i, r) in table.enumerated() {
        if byteOffset > r.0 && (i == table.count - 1 || byteOffset <= table[i + 1].0) {
          return byteOffset - r.1
        }
      }
      return byteOffset
    }
    
    func map(_ range: Range<Int>) -> Range<Int> {
      let lo = at(range.lowerBound)
      return range.isEmpty ? lo..<lo : lo..<at(range.upperBound)
    }
  }
    
  /// Creates a mapping table from *bytes* indices in `enc1` to indices in `enc2`
  func createOffsetTable<From, To>(from enc1: From.Type, to enc2: To.Type) -> OffsetTable
    where From: UnicodeScalarWidthProvider, To: UnicodeScalarWidthProvider
  {
      
    var index: Int = 0
    var offset: Int = 0
    var table: [(Int, Int)] = []
    
    unicodeScalars.forEach {
      let width1 = enc1.width($0)
      let diff = width1 - enc2.width($0)
      if diff != 0 {
        offset += diff
        table.append((index, offset))
      }
      index += width1
    }
    
    return OffsetTable(table)
  }
}

protocol UnicodeScalarWidthProvider {
  static func width(_ x: Unicode.Scalar) -> Int
}

extension UTF8: UnicodeScalarWidthProvider {}
extension UTF16: UnicodeScalarWidthProvider {}
