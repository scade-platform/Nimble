//
//  Observer.swift
//  NimbleCore
//
//  Created by Grigory Markin on 12.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

fileprivate struct ObserverRef<T> {
  weak var object: AnyObject?
  var value: T? { object as? T }
}

public struct ObserverSet<T> {
  fileprivate var observers: [ObjectIdentifier: ObserverRef<T>] = [:]

  private init(_ observers: [ObjectIdentifier: ObserverRef<T>]) {
    self.observers = observers
  }
  
  public init() { }
  
  public mutating func add(observer: T) {
    let obj = observer as AnyObject
    let key = ObjectIdentifier(obj)
    observers[key] = ObserverRef<T>(object: obj)
  }
  
  public mutating func remove(observer: T) {
    // Casting to AnyObject always succeeds, even for enum types
    let obj = observer as AnyObject
    let key = ObjectIdentifier(obj)
    observers.removeValue(forKey: key)
  }
  
  public mutating func notify(with notifier: (T) -> Void) {
    for (id, ref) in observers {
      guard let observer = ref.value else {
        observers.removeValue(forKey: id)
        continue
      }
      notifier(observer)
    }
  }
  
  public mutating func notify<R>(as: R.Type, with notifier: (R) -> Void) {
    notify {
      guard let casted = $0 as? R else { return }
      notifier(casted)
    }
  }
    
  public var isEmpty : Bool {
    return observers.isEmpty
  }
}


public protocol Observable {
  associatedtype ObserverType  
  var observers: ObserverSet<ObserverType> { get }
}

