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
    self.publish(task: t) { _ in
      onComplete?(tasks)
    }
    try t.run()
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
        DispatchQueue.main.async {
          self.workbench.publish(task: t) {_ in
            //stop waiting
            semaphore.signal()
          }
        }
        do {
          //run task
          try t.run()
        } catch {
          print(error)
          return
        }
        //wait until task complete
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
