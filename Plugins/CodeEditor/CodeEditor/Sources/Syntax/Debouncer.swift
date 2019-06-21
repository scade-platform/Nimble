//
//  Debouncer.swift
//
//  CodeEditor
//
//  Created by Mark Goldin on 19/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Dispatch

/// Object invoking the registered block when a specific time interval is passed after the last call.
final class Debouncer {
    
    // MARK: Private Properties
    
    private let action: () -> Void
    private let queue: DispatchQueue
    private let defaultDelay: DispatchTimeInterval
    
    private var currentWorkItem: DispatchWorkItem?
    
    
    
    // MARK: -
    // MARK: Lifecycle
    
    /// Returns a new `Debouncer` initialized with given values.
    ///
    /// - Parameters:
    ///   - delay: The default time to wait since last call.
    ///   - queue: The dispatch queue to perform action.
    ///   - action: The action to debounce.
    init(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping () -> Void) {
        
        self.action = action
        self.queue = queue
        self.defaultDelay = delay
    }
    
    
    deinit {
        self.cancel()
    }
    
    
    
    // MARK: Public Methods
    
    /// Invoke the action after when `delay` time have passed since last call.
    ///
    /// - Parameters:
    ///   - delay: The time to wait for fire. If nil, receiver's default delay is used.
    func schedule(delay: DispatchTimeInterval? = nil) {
        
        let delay = delay ?? self.defaultDelay
        let workItem = DispatchWorkItem { [weak self] in
            self?.action()
            self?.currentWorkItem = nil
        }
        
        self.cancel()
        self.currentWorkItem = workItem
        
        self.queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        
    }
    
    
    /// Perform the action immediately.
    func perform() {
        
        self.currentWorkItem?.cancel()
        self.queue.async(execute: self.action)
    }
    
    
    /// Perform the action immediately if scheduled.
    func fireNow() {
        
        self.currentWorkItem?.perform()
    }
    
    
    /// Cancel the action if scheduled.
    func cancel() {
        
        self.currentWorkItem?.cancel()
        self.currentWorkItem = nil
    }
    
}
