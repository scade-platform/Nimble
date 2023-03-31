//
//  Observer.swift
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

  public func notify(with notifier: (T) -> Void) {
    self.observers.values.forEach {
      guard let observer = $0.value else { return }
      notifier(observer)
    }
  }

  public func notify<R>(as: R.Type, with notifier: (R) -> Void) {
    notify {
      guard let casted = $0 as? R else { return }
      notifier(casted)
    }
  }

//  public mutating func notify(with notifier: (T) -> Void) {
//    let observers = self.observers.map{$0}
//    for (id, ref) in observers {
//      guard let observer = ref.value else {
//        self.observers.removeValue(forKey: id)
//        continue
//      }
//      notifier(observer)
//    }
//  }
//
//  public mutating func notify<R>(as: R.Type, with notifier: (R) -> Void) {
//    notify {
//      guard let casted = $0 as? R else { return }
//      notifier(casted)
//    }
//  }
    
  public var isEmpty : Bool {
    return observers.isEmpty
  }
}


public protocol Observable {
  associatedtype ObserverType  
  var observers: ObserverSet<ObserverType> { get }
}

