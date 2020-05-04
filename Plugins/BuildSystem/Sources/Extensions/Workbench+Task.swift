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
  func publish(tasks: [WorkbenchTask], then handler: @escaping (Outcome) -> Void) {
    Task.sequence(tasks.map{WorkbenchTaskWrapper($0)}.map{Task.execute($0, in: self)}).perform(then: handler)
  }
}

enum Outcome {
  case success
  case failure(Error)
}

fileprivate struct Task {
  typealias Closure = (Controller) -> Void
  
  private let closure: Closure
  
  init(closure: @escaping Closure) {
    self.closure = closure
  }
}

extension Task {
  struct Controller {
    fileprivate let queue: DispatchQueue
    fileprivate let handler: (Outcome) -> Void
    
    func finish() {
      handler(.success)
    }
    
    func fail(with error: Error) {
      handler(.failure(error))
    }
  }
}

extension Task {
  func perform(on queue: DispatchQueue = .global(),
               then handler: @escaping (Outcome) -> Void) {
    queue.async {
      let controller = Controller(
        queue: queue,
        handler: handler
      )
      
      self.closure(controller)
    }
  }
}

extension Task {
  
  static func execute(_ task: WorkbenchTaskWrapper, in workbench: Workbench) -> Task {
    return Task { controller in
      do {
        try task.run {
          controller.finish()
        }
        workbench.publish(task: task)
      } catch {
        controller.fail(with: error)
      }
    }
  }
}

extension Task {
  static func sequence(_ tasks: [Task]) -> Task {
    var index = 0
    
    func performNext(using controller: Controller) {
      guard index < tasks.count else {
        // We’ve reached the end of our array of tasks,
        // time to finish the sequence.
        controller.finish()
        return
      }
      
      let task = tasks[index]
      index += 1
      
      task.perform { outcome in
        switch outcome {
        case .success:
          performNext(using: controller)
        case .failure(let error):
          // As soon as an error was occurred, we’ll
          // fail the entire sequence.
          controller.fail(with: error)
        }
      }
    }
    return Task(closure: performNext)
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
