//
//  RandomAccessCollection.swift
//  NimbleCore
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
