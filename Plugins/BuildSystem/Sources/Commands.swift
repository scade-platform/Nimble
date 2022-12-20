//
//  BuildCommands.swift
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

import AppKit
import NimbleCore
import BuildSystem


// MARK: - Basic

class BuildSystemCommand: Command {
  init(name: String, keyEquivalent: String? = nil, toolbarIcon: NSImage? = nil, orderPriority: Int = 100) {
    super.init(name: name,
               keyEquivalent: keyEquivalent,
               toolbarIcon: toolbarIcon,
               alignment: .left(orderPriority: orderPriority))
  }

  func currentTask(in workbench: Workbench) -> BuildTask? {
    return workbench.tasks.first { $0 is BuildTask } as? BuildTask
  }
}



// MARK: - Run

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


// MARK: - Stop

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


// MARK: - Build

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


// MARK: - Clean

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

final class CleanAll: BuildSystemCommand {
  init() {
    super.init(name: "Clean All")
  }
  
  override func run(in workbench: Workbench) {
    ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
    //Clean all targets with build system which was selected in the target selector
    guard let buildSystem = workbench.selectedVariant?.buildSystem else {
      return
    }
    let targets = buildSystem.targets(in: workbench)
    targets.forEach{ target in
      target.variants.forEach{ variant in
        buildSystem.clean(variant)
      }
    }
  }
  
  override func validate(in workbench: Workbench) -> State {
    return currentTask(in: workbench) == nil ? [.enabled] : []
  }
}


// MARK: - Select target

final class SelectTarget: Command {
  init() {
    super.init(name: "Select Target",
               menuPath: nil,
               keyEquivalent: nil,
               controlClass: ToolbarTargetControl.self,
               alignment: .left(orderPriority: 30))
  }

  override func validate(in workbench: Workbench, control: NSControl?) -> State {
    guard let selector = control as? ToolbarTargetControl else { return .disabled }
    return selector.activeVariant != nil ? .enabled : .disabled
  }
}
