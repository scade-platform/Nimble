//
//  Commands.swift
//  BuildSystem
//
//  Created by Grigory Markin on 24.04.20.
//  Copyright © 2020 Scade. All rights reserved.
//

import AppKit
import NimbleCore

// MARK: - Run command

final class Run: BuildSystemCommand {
  init() {
    super.init(name: "Run", keyEquivalent: "cmd+r", toolbarIcon: IconsManager.Icons.run.image)
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
    super.init(name: "Stop", keyEquivalent: "cmd+.", toolbarIcon: IconsManager.Icons.stop.image)
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
    let view = ToolbarTargetControl.loadFromNib()
    super.init(name: "Select Target", menuPath: nil, keyEquivalent: nil, view: view)
  }
  
  override func validate(in workbench: Workbench) -> State {
    guard let activeSystem = BuildSystemsManager.shared.activeBuildSystem else { return [] }
    return activeSystem.targets(in: workbench).isEmpty ? [] : [.enabled]
  }
}


// MARK: - Basic build command

class BuildSystemCommand: Command {
  init(name: String, keyEquivalent: String, toolbarIcon: NSImage? = nil) {
    super.init(name: name, menuPath: "Tools", keyEquivalent: keyEquivalent, toolbarIcon: toolbarIcon)
  }

  func currentTask(in workbench: Workbench) -> BuildSystemTask? {
    return workbench.tasks.first { $0 is BuildSystemTask } as? BuildSystemTask
  }
}

// MARK: - Build system task
class BuildSystemTask: WorkbenchProcess {}
