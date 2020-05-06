//
//  BuildSystemTask.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 06.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import NimbleCore
import AppKit

class BuildSystemTask: WorkbenchProcess {}

class ConsoleOutputWorkbenchProcess: BuildSystemTask {
  let process: Process
  var console: Console?
  
  init(_ process: Process, title: String, target: Target, handler: ((Console) -> Void)? = nil) {
    self.process = process
    super.init(process)
    self.console = openConsole(for: process, consoleTitle: title, target: target)
    let superTerminateHandler = process.terminationHandler
    process.terminationHandler = {[weak self] process in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        if let console = self.console {
          handler?(console)
          
          if console.contents.isEmpty {
            console.close()
          }
        }
        self.console?.stopReadingFromBuffer()
        superTerminateHandler?(process)
      }
      
    }
  }
  
  private func openConsole(for process: Process, consoleTitle title: String, target: Target) -> Console? {
    guard let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: target.id, title: title, in: workbench),
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
