//
//  Workbench+Task.swift
//  BuildSystem
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
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

import Cocoa

public extension Workbench {
  func publish(tasks: [WorkbenchTask], onComplete: (([WorkbenchTask]) -> Void)? = nil) throws {
    let t = SequenceTask(tasks, in: self)
    self.publish(task: t) { _ in
      onComplete?(tasks)
    }
    try t.run()
  }
}
  
public class SequenceTask: WorkbenchTask {
  var atomicIsRunning = Atomic<Bool>(false)
  
  public var isRunning: Bool {
    get {
      atomicIsRunning.value
    }
    set {
      atomicIsRunning.modify{value in value = newValue}
    }
  }
  
  
  public func stop() {
  }
  
  public var observers = ObserverSet<WorkbenchTaskObserver>()
  let workbench: Workbench
  fileprivate let queue: DispatchQueue

  
  public let subTasks: [WorkbenchTask]

  
  public func run() throws {
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
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.observers.notify{$0.taskDidFinish(self)}
      }
    }
  }
  
  public init(_ tasks: [WorkbenchTask], in workbench: Workbench) {
    self.subTasks = tasks
    self.workbench = workbench
    self.queue = .global()
  }
}
