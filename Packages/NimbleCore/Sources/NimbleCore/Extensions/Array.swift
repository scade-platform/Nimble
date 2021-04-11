//
//  Array.swift
//  
//
//  Created by Grigory Markin on 11.04.21.
//

public extension Array {
  subscript(safe index: Int) -> Element? {
    guard index >= 0, index < endIndex else { return nil }
    return self[index]
  }

  subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
    guard index >= 0, index < endIndex else { return defaultValue() }
    return self[index]
  }
}
