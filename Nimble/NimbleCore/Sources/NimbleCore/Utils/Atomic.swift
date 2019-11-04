//
//  Atomic.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.10.19.
//

import Foundation

final public class Atomic<A> {
  private let queue: DispatchQueue
  private var _value: A
  
  public init(_ value: A, attributes: DispatchQueue.Attributes = []) {
    let label = "com.nimble.utils.atomic.\(String(describing: A.self))"
    self.queue = DispatchQueue(label: label, attributes: attributes)
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
  public func asyncModify(_ modify: @escaping (inout A) -> ()) {
    queue.async(flags: .barrier) { [unowned self] in
      modify(&self._value)
    }
  }
}

