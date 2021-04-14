//
//  BuildSystemModule.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 02/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
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
    
    Settings.shared.add(OSLog.$logsSystems)
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
    CommandManager.shared.register(commands: [Run(), Stop(), Build(), Clean(), CleanAll(), SelectTarget()])
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

// MARK: - OSLog utils

///TODO: remove it or move somewhere else "nimble.log" setting in the BuildSystem plugin ????!!!!!!!

extension OSLog {
  private static let subsystem = "com.nimble.BuildSystem"

  static let targetSelector = OSLog(subsystem: subsystem, category: "targetSelector")

  @Setting("nimble.log", defaultValue: [])
  public static var logsSystems: [String]

  static var isLogOn : Bool {
    return OSLog.logsSystems.contains(OSLog.subsystem)
  }
}
