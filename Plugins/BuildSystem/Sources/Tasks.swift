//
//  Tasks.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 30.04.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import NimbleCore
import AppKit

class OutputConsoleTask: WorkbenchProcess {
  var console: Console?
  var consoleObserver: OutputConsoleTaskObserver?
  var callBack: ((WorkbenchTask) throws -> Void)?
  
  init(_ process: Process, target: Target, consoleTitle title: String, consoleObserver: OutputConsoleTaskObserver? = nil, callBack: ((WorkbenchTask) throws -> Void)? = nil) throws {
    super.init(process)
    self.consoleObserver = consoleObserver
    self.callBack = callBack
    console = openConsole(for: process, target: target, consoleTitle: title)
    self.observers.add(observer: self)
    try process.run()
  }
  
  private func openConsole(for process: Process, target: Target, consoleTitle title: String) -> Console? {
    guard let workbench = target.workbench, let console = openConsole(key: target.sourceName, title: title, in: workbench),
      !console.isReadingFromBuffer
      else {
        //The console is using by another process with the same representedObject
        return nil
    }
    
    process.standardOutput = console.output
    process.standardError = console.output
    console.startReadingFromBuffer()
    
    self.consoleObserver?.consoleStartReading(console)
    
    return console
  }

}

extension OutputConsoleTask : WorkbenchTaskObserver {
  func taskDidFinish(_ task: WorkbenchTask) {
    guard let console = self.console else {
      return
    }
    self.consoleObserver?.consoleStopReading(console)
    
    console.stopReadingFromBuffer()
    try? callBack?(self)
  }
}

extension OutputConsoleTask : ConsoleSupport {}

protocol  OutputConsoleTaskObserver {
  func consoleStartReading(_ console: Console)
  func consoleStopReading(_ console: Console)
}

