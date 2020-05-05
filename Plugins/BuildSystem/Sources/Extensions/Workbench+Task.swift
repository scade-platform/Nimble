//
//  Workbench+Task.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 02.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

extension Workbench {
  func publish(tasks: [WorkbenchTask], onComplete: (([WorkbenchTask]) -> Void)? = nil) throws {
    let t = SequenceTask(tasks, in: self)
    try self.publish(t) { _ in
      onComplete?(tasks)
    }
  }
  
  func publish(_ task: WorkbenchTask, onComplete: @escaping (WorkbenchTask) -> Void) throws {
    let wrappedTask = WorkbenchTaskWrapper(task)
    try wrappedTask.run {
      onComplete(task)
    }
    self.publish(task: wrappedTask)
  }
}

class SequenceTask: WorkbenchTask {
  var atomicIsRunning = Atomic<Bool>(false)
  
  var isRunning: Bool {
    get {
      atomicIsRunning.value
    }
    set {
      atomicIsRunning.modify{value in value = newValue}
    }
  }
  
  func stop() {
  }
  
  var observers = ObserverSet<WorkbenchTaskObserver>()
  let workbench: Workbench
  fileprivate let queue: DispatchQueue

  
  let subTasks: [WorkbenchTask]

  
  func run() throws {
    queue.async { [weak self] in
      guard let self = self else { return }
      let semaphore = DispatchSemaphore(value: 0)
      self.isRunning = true
      for t in self.subTasks {
        do {
          try self.workbench.publish(t) {_ in
            semaphore.signal()
          }
        } catch {
          print(error)
          return
        }
        semaphore.wait()
      }
      self.isRunning = false
      self.observers.notify{$0.taskDidFinish(self)}
    }
  }
  
  init(_ tasks: [WorkbenchTask], in workbench: Workbench) {
    self.subTasks = tasks
    self.workbench = workbench
    self.queue = .global()
  }
}

fileprivate class WorkbenchTaskWrapper: WorkbenchTask {
  let innerWorkbenchTask: WorkbenchTask
  var handler: (() -> Void)?
  
  var observers: ObserverSet<WorkbenchTaskObserver> {
    get {
      innerWorkbenchTask.observers
    }
    set {
      innerWorkbenchTask.observers = newValue
    }
  }
  
  var isRunning: Bool {
    innerWorkbenchTask.isRunning
  }
  
  func stop() {
    innerWorkbenchTask.stop()
  }
  
  func run() throws {
    try innerWorkbenchTask.run()
  }
  
  func run(then handler: @escaping () -> Void) throws {
    self.handler = handler
    try self.run()
  }
  
  init(_ task: WorkbenchTask) {
    self.innerWorkbenchTask = task
    self.innerWorkbenchTask.observers.add(observer: self)
  }
}

extension WorkbenchTaskWrapper: WorkbenchTaskObserver {
  func taskDidFinish(_ task: WorkbenchTask) {
    guard task === innerWorkbenchTask else {
      return
    }
    handler?()
  }
}
