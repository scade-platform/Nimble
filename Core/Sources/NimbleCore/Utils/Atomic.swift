//
//  Atomic.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.10.19.
//

import Foundation

final public class Atomic<A> {
  private let queue = DispatchQueue(label: "com.nimble.utils.Atomic")
  private var _value: A
  
  public init(_ value: A) {
    self._value = value
  }
  
  public var value: A {
    get {
      return queue.sync { self._value }
    }
  }
  
  public func modify(_ modify: (inout A) -> ()) {
    queue.sync {
      modify(&self._value)
    }
  }
}
