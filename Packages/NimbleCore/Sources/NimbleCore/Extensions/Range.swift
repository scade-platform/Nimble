//
//  File.swift
//  
//
//  Created by Grigory Markin on 21.01.21.
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


public extension Array where Element: RangeSet {
  func union() -> Element? {
    guard let acc = self.first else { return nil }
    return self[1...].reduce(acc) { $0.union(with: $1) }
  }
}
