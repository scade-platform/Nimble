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
  
  init(_ process: Process, target: Target, consoleTitle title: String) throws {
    super.init(process)
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
    
    return console
  }

}

extension OutputConsoleTask : WorkbenchTaskObserver {
  func taskDidFinish(_ task: WorkbenchTask) {
    self.console?.stopReadingFromBuffer()
  }
}

extension OutputConsoleTask : ConsoleSupport {}
