//
//  Commands.swift
//  BuildSystem
//
//  Created by Grigory Markin on 24.04.20.
//  Copyright © 2020 Scade. All rights reserved.
//

import AppKit
import NimbleCore
import BuildSystem
import os.log

// MARK: - Run command

final class Run: BuildSystemCommand {
  init() {
    super.init(name: "Run", keyEquivalent: "cmd+r", toolbarIcon: IconsManager.Icons.run.image, orderPriority: 10)
  }

  override func run(in workbench: Workbench) {
    ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
    guard let variant = workbench.selectedVariant else {
      return
    }
    BuildSystemsManager.shared.activeBuildSystem?.run(variant)
  }
  
  override func validate(in workbench: Workbench) -> State {
    return currentTask(in: workbench) == nil ? [.enabled] : []
  }
}


// MARK: - Stop command

final class Stop: BuildSystemCommand {
  init() {
    super.init(name: "Stop", keyEquivalent: "cmd+.", toolbarIcon: IconsManager.Icons.stop.image, orderPriority: 20)
  }

  override func run(in workbench: Workbench) {
    guard let task = currentTask(in: workbench) else { return }

    if task.isRunning {
      task.stop()
    }
    ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
  }

  override func validate(in workbench: Workbench) -> State {
    return currentTask(in: workbench) != nil ? [.enabled] : []
  }
}


// MARK: - Build command

final class Build: BuildSystemCommand {
  init() {
    super.init(name: "Build", keyEquivalent: "cmd+b")
  }

  override func run(in workbench: Workbench) {
    ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
    guard let variant = workbench.selectedVariant else {
      return
    }
    BuildSystemsManager.shared.activeBuildSystem?.build(variant)
  }

  override func validate(in workbench: Workbench) -> State {
    return currentTask(in: workbench) == nil ? [.enabled] : []
  }
}

final class Clean: BuildSystemCommand {
  init() {
    super.init(name: "Clean", keyEquivalent: "cmd+K")
  }

  override func run(in workbench: Workbench) {
    ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
    guard let variant = workbench.selectedVariant else {
      return
    }
    BuildSystemsManager.shared.activeBuildSystem?.clean(variant)
  }

  override func validate(in workbench: Workbench) -> State {
    return currentTask(in: workbench) == nil ? [.enabled] : []
  }
}

final class SelectTarget: Command {
  
  
  init() {
    super.init(name: "Select Target", menuPath: nil, keyEquivalent: nil, controlClass: ToolbarTargetControl.self, alignment: .left(orderPriority: 30))
  }
  
  override func validate(in workbench: Workbench, control: NSControl?) -> State {
    if OSLog.isLogOn {
      os_log("Validation target selector.", log: .targetSelector, type: .info)
    }
    
    guard let activeSystem = BuildSystemsManager.shared.activeBuildSystem, !activeSystem.targets(in: workbench).isEmpty else { return [] }
    if let toolbarTargetControl = control as? ToolbarTargetControl {
      
      if OSLog.isLogOn {
        if let target = toolbarTargetControl.target, let targetDescription = target.description {
          os_log("Control: %{public}s, target: %{public}s", log: .targetSelector, type: .info, toolbarTargetControl.description, targetDescription)
        } else {
          os_log("Control: %{public}s without target", log: .targetSelector, type: .info, toolbarTargetControl.description)
        }
      }
      
      workbench.observers.add(observer: toolbarTargetControl)
      BuildSystemsManager.shared.observers.add(observer: toolbarTargetControl)
      toolbarTargetControl.autoSelectTarget(in: workbench)
      return [.enabled]
    }
    return []
  }
}


// MARK: - Basic build command

class BuildSystemCommand: Command {
  init(name: String, keyEquivalent: String, toolbarIcon: NSImage? = nil, orderPriority: Int = 100) {
    super.init(name: name, menuPath: "Tools", keyEquivalent: keyEquivalent, toolbarIcon: toolbarIcon, alignment: .left(orderPriority: orderPriority))
  }

  func currentTask(in workbench: Workbench) -> BuildTask? {
    return workbench.tasks.first { $0 is BuildTask } as? BuildTask
  }
}
