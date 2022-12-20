//
//  BuildSystemModule.swift
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
import NimbleCore
import BuildSystem
import os.log

public final class BuildSystemModule: Module {
  public static let plugin: Plugin = BuildSystemPlugin()
}

final class BuildSystemPlugin: Plugin {
  weak var buildSystemMenu: NSMenu?
  
  func load() {
    setupMainMenu()
    setupCommands()
    
    BuildSystemsManager.shared.observers.add(observer: self)
  }

  public func activate(in workbench: Workbench) {
    BuildSystemsManager.shared.connect(to: workbench)    
  }

  public func deactivate(in workbench: Workbench) {
    BuildSystemsManager.shared.disconnect(from: workbench)    
  }

  func encodeRestorableState(in workbench: Workbench, coder: NSCoder) -> Void {
    guard let variant = workbench.selectedVariant,
          let target = variant.target else { return }

    coder.encode(target.name, forKey: "ActiveTarget")
    coder.encode(variant.name, forKey: "ActiveVariant")
    coder.encode(target.buildSystem.name, forKey: "ActiveBuildSystem")
  }

  func restoreState(in workbench: Workbench, coder: NSCoder) -> Void {
    guard let targetName = coder.decodeObject(forKey: "ActiveTarget") as? String,
          let variantName = coder.decodeObject(forKey: "ActiveVariant") as? String,
          let systemName = coder.decodeObject(forKey: "ActiveBuildSystem") as? String,
          let variant = BuildSystemsManager.shared.find(
            variant: (variantName, targetName, systemName), in: workbench) else { return }

      workbench.selectedVariant = variant
  }

  private func setupMainMenu() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    guard let toolsMenu = mainMenu.findItem(with: "Tools")?.submenu else { return }
    
    let buildSystemMenuItem = NSMenuItem(title: "Build System", action: nil, keyEquivalent: "")
    let buildSystemMenu = NSMenu(title: "Build System")
    buildSystemMenuItem.submenu = buildSystemMenu
    toolsMenu.addItem(buildSystemMenuItem)
    toolsMenu.addItem(.separator())

    let autoItem = NSMenuItem(title: "Automatic", action: #selector(switchBuildSystem(_:)), keyEquivalent: "")
    autoItem.target = self
    autoItem.representedObject = Automatic.shared
    buildSystemMenu.addItem(autoItem)
    buildSystemMenu.addItem(.separator())

    let tools = BuildSystemsManager.shared.buildSystems
    for tool in tools {
      let toolItem = NSMenuItem(title: tool.name, action: #selector(switchBuildSystem(_:)), keyEquivalent: "")
      toolItem.target = self
      toolItem.representedObject = tool
      buildSystemMenu.addItem(toolItem)
    }
    
    self.buildSystemMenu = buildSystemMenu
  }
  
  private func setupCommands() {    
    CommandManager.shared.register(commands: [Run(), Stop(), Build(), Clean(), CleanAll()],
                                   group: "Build Commands",
                                   menuPath: "Tools",
                                   toolbarGroup: false,
                                   alignment: .left(orderPriority: 10))

    CommandManager.shared.register(command: SelectTarget())
  }
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else {return true}
    let itemTool = item.representedObject as AnyObject?
    let currentTool = BuildSystemsManager.shared.activeBuildSystem as AnyObject?
    item.state = (itemTool === currentTool) ? .on : .off
    return true
  }
  
  @objc func switchBuildSystem(_ item: NSMenuItem?) {
    BuildSystemsManager.shared.activeBuildSystem = item?.representedObject as? BuildSystem
  }
}

extension BuildSystemPlugin: BuildSystemsObserver {
  func buildSystemDidRegister(_ buildSystem: BuildSystem) {
    guard let buildSystemMenu = buildSystemMenu else { return }

    let toolItem = NSMenuItem(title: buildSystem.name, action: #selector(switchBuildSystem(_:)), keyEquivalent: "")
    toolItem.target = self
    toolItem.representedObject = buildSystem

    buildSystemMenu.addItem(toolItem)
  }
}

