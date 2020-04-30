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
    showConsoleTillFirstEscPress(in: workbench)
    //TODO: improve call using new API
    guard let variant = workbench.selectedVariant else {
      return
    }
    do {
      let buildTask = try variant.build { variant, task in
        workbench.publish(task: try variant.run())
      }
      workbench.publish(task: buildTask)
    } catch {
      print(error)
    }
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
    showConsoleTillFirstEscPress(in: workbench)
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
    showConsoleTillFirstEscPress(in: workbench)
    //TODO: improve call using new API
//    BuildSystemsManager.shared.activeBuildSystem?.run(in: workbench) {[weak self] status, process in
//        switch status {
//        case .finished:
//          self?.showConsoleTillFirstEscPress(in: workbench)
//        case .running:
//          workbench.publish(process)
//        case .failed:
//          return
//        }
//      }
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
    showConsoleTillFirstEscPress(in: workbench)
    //TODO: improve call using new API
//    BuildSystemsManager.shared.activeBuildSystem?.clean(in: workbench)
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
    return BuildSystemsManager.shared.buildSystems.hasTargets(in: workbench) ? [.enabled] : []
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

  func showConsoleTillFirstEscPress(in workbench: Workbench) {
    var escPressMonitor: Any? = nil
    escPressMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
      if event.keyCode == Keycode.escape {
        workbench.debugArea?.isHidden = true
        if let monitor = escPressMonitor {
          //only for first `esc` press
          NSEvent.removeMonitor(monitor)
          escPressMonitor = nil
        }
      }
      return event
    }

    workbench.debugArea?.isHidden = false
  }
}


// MARK: - Build system task

class BuildSystemTask: WorkbenchProcess {}

fileprivate extension Workbench {
  func publish(_ process: Process?) {
    guard let process = process, process.isRunning else { return }
    self.publish(task: BuildSystemTask(process))
  }
}



