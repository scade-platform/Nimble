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

    BuildSystemsManager.shared.activeBuildSystem?.run(in: workbench) { [weak self] status, process in
      switch status {
      case .finished:
        DispatchQueue.main.async { [weak self] in
          self?.showConsoleTillFirstEscPress(in: workbench)
          BuildSystemsManager.shared.activeBuildSystem?.launcher?.launch(in: workbench, handler: self?.launcherHandler(status:process:))
        }
      case .failed, .running:
        self?.launcherHandler(status: status, process: process)
      }
    }
  }

  override func validate(in workbench: Workbench) -> State {
    return currentProcess == nil ? [.enabled] : []
  }
}


// MARK: - Stop command

final class Stop: BuildSystemCommand {
  init() {
    super.init(name: "Stop", keyEquivalent: "cmd+.", toolbarIcon: IconsManager.Icons.stop.image)
  }

  override func run(in workbench: Workbench) {
    guard let process = currentProcess else { return }

    if process.isRunning {
      process.terminate()
    }
    showConsoleTillFirstEscPress(in: workbench)
  }

  override func validate(in workbench: Workbench) -> State {
    return currentProcess != nil ? [.enabled] : []
  }
}


// MARK: - Build command

final class Build: BuildSystemCommand {
  init() {
    super.init(name: "Build", keyEquivalent: "cmd+b")
  }

  override func run(in workbench: Workbench) {
    showConsoleTillFirstEscPress(in: workbench)
    BuildSystemsManager.shared.activeBuildSystem?.run(in: workbench, handler: launcherHandler(status:process:))
  }

  override func validate(in workbench: Workbench) -> State {
    return currentProcess == nil ? [.enabled] : []
  }
}

final class Clean: BuildSystemCommand {
  init() {
    super.init(name: "Clean", keyEquivalent: "cmd+K")
  }

  override func run(in workbench: Workbench) {
    showConsoleTillFirstEscPress(in: workbench)
    BuildSystemsManager.shared.activeBuildSystem?.clean(in: workbench)
  }

  override func validate(in workbench: Workbench) -> State {
    return currentProcess == nil ? [.enabled] : []
  }
}


// MARK: - Basic build command

class BuildSystemCommand: Command {
  var currentProcess: Process? {
    get { return (BuildSystemModule.plugin as? BuildSystemPlugin)?.currentProcess }
    set { (BuildSystemModule.plugin as? BuildSystemPlugin)?.currentProcess = newValue }
  }

  init(name: String, keyEquivalent: String, toolbarIcon: NSImage? = nil) {
    super.init(name: name, menuPath: "Tools", keyEquivalent: keyEquivalent, toolbarIcon: toolbarIcon)
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

  func launcherHandler(status: BuildStatus, process: Process?) -> Void {
    if status == .running && process?.isRunning ?? false {
      currentProcess = process
    } else {
      currentProcess = nil
    }
  }
}
