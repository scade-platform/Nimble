//
//  Atomic.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Dispatch

final class Atomic<T> {
    
    // MARK: Private Properties
    
    private let queue: DispatchQueue
    private var _value: T
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    init(_ value: T, attributes: DispatchQueue.Attributes = []) {
        
        self.queue = DispatchQueue(label: "com.coteditor.CotEdiotor.atomic." + String(describing: T.self), attributes: attributes)
        self._value = value
    }
    
    
    
    // MARK: Public Methods
    
    /// thread-safe getter for value
    var value: T {
        
        return self.queue.sync { self._value }
    }
    
    
    /// thread-safe update of value
    func mutate(_ transform: (inout T) -> Void) {
        
        self.queue.sync {
            transform(&self._value)
        }
    }
    
    
    /// thread-safe update of value without blocking the current thread
    func asyncMutate(_ transform: @escaping (inout T) -> Void) {
        
        self.queue.async(flags: .barrier) { [unowned self] in
            transform(&self._value)
        }
    }
    
}
