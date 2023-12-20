//
//  Range.swift
//  NimbleCore
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


public protocol RangeSet {
  func union(with other: Self) -> Self
  func intersection(with other: Self) -> Self?
}

extension Range: RangeSet where Bound: Comparable {
  public func union(with other: Range) -> Range {
    return Swift.min(self.lowerBound, other.lowerBound)..<Swift.max(self.upperBound, other.upperBound)
  }

  public func intersection(with other: Range) -> Range? {
    guard self.upperBound > other.lowerBound && self.lowerBound < other.upperBound else { return nil }
    return Swift.max(self.lowerBound, other.lowerBound)..<Swift.min(self.upperBound, other.upperBound)
  }
}


extension Range where Bound: Numeric {
  public func offset(by distance: Bound) -> Range<Bound> {
    return self.lowerBound + distance..<self.upperBound + distance
  }
}


public extension Array where Element: RangeSet {
  func union() -> Element? {
    guard let acc = self.first else { return nil }
    return self[1...].reduce(acc) { $0.union(with: $1) }
  }
}
