//
//  PluginResources.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 01.04.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore

extension Workbench {
  var buildProcess: Process? {
    get {
      return ProcessesStorage.shared.process(from: self)
    }
    set {
      if let newProcess = newValue {
        ProcessesStorage.shared.save(newProcess, for: self)
      } else {
        ProcessesStorage.shared.removeProcess(for: self)
      }
    }
  }
  
  subscript(command: Command) -> CommandState? {
    return self.commandSates[command]
  }
}


class ProcessesStorage {
  static let shared = ProcessesStorage()
  private var processByWorkbench : [NSObject: Process] = [:]
  
  @discardableResult
  func save(_ process: Process, for workbench: Workbench) -> Process? {
    guard let object = workbench as? NSObject else { return nil }
    let oldProcess = processByWorkbench[object]
    processByWorkbench[object] = process
    return oldProcess
  }
  
  func process(from workbench: Workbench) -> Process? {
    guard let object = workbench as? NSObject else { return nil }
    return processByWorkbench[object]
  }
  
  @discardableResult
  func removeProcess(for workbench: Workbench) -> Process? {
    guard let object = workbench as? NSObject else { return nil }
    let removedProcess = processByWorkbench[object]
    processByWorkbench[object] = nil
    return removedProcess
  }
}
