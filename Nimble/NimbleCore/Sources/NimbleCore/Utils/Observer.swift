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

public class ObserverSet<T> {
  fileprivate var observers: [ObjectIdentifier: ObserverRef<T>] = [:]
  
  var delegate: ObserverSetDelegate?
  
  public init() { }
  
  public func add(observer: T) {
    let obj = observer as AnyObject
    let key = ObjectIdentifier(obj)
    delegate?.observerWillAdd(obj)
    observers[key] = ObserverRef<T>(object: obj)
    delegate?.observerDidAdd(obj)
  }
  
  public func remove(observer: T) {
    // Casting to AnyObject always succeeds, even for enum types
    let obj = observer as AnyObject
    let key = ObjectIdentifier(obj)
    delegate?.observerWillRemove(obj)
    observers.removeValue(forKey: key)
    delegate?.observerDidRemove(obj)
  }
  
  public func notify(with notifier: (T) -> Void) {
    for (id, ref) in observers {
      guard let observer = ref.value else {
        observers.removeValue(forKey: id)
        delegate?.observerDidRelease()
        continue
      }
      notifier(observer)
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

public protocol ObserverSetDelegate {
  func observerWillAdd(_ observer: AnyObject)
  func observerDidAdd(_ observer: AnyObject)
  func observerWillRemove(_ observer: AnyObject)
  func observerDidRemove(_ observer: AnyObject)
  func observerDidRelease()
}

public extension ObserverSetDelegate {
  //default implementation
  func observerWillAdd(_ observer: AnyObject) {}
  func observerDidAdd(_ observer: AnyObject) {}
  func observerWillRemove(_ observer: AnyObject) {}
  func observerDidRemove(_ observer: AnyObject) {}
  func observerDidRelease(){}
}
