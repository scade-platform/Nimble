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
    CommandManager.shared.register(commands: [Run(), Stop(), Build(), Clean(), SelectTarget()])
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
