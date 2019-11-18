//
//  RandomAccessCollection.swift
//  NimbleCore
//
//  Created by Grigory Markin on 05.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation


public extension RandomAccessCollection {
  func binarySearch(cond: (Element) -> Bool) -> Index {
    var begin = startIndex
    var end = endIndex
    
    if begin == end || (cond(self[index(before: end)])) {
      return end
    }
      
    while begin != end {
      let pos = index(begin, offsetBy: distance(from: begin, to: end) / 2)
      if cond(self[pos]) {
        begin = index(after: pos)
      } else {
        end = pos
      }
    }
    return begin
  }
}
