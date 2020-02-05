//
//  BuildSystemModule.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 02/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import NimbleCore
import Cocoa

public final class BuildSystemModule: Module {
  public static let plugin: Plugin = BuildSystemPlugin()
}

final class BuildSystemPlugin: Plugin {
  init() {
    BuildSystemsManager.shared.add(buildSystem: SwiftBuildSystem())
    BuildSystemsManager.shared.add(buildSystem: SPMBuildSystem())
    setupMainMenu()
    setupCommands()
  }
    
  private func setupMainMenu() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    guard let toolsMenu = mainMenu.findItem(with: "Tools")?.submenu else { return }
    
    let buildSystemMenuItem = NSMenuItem(title: "Build System", action: nil, keyEquivalent: "")
    let submenu = NSMenu(title: "Build System")
    buildSystemMenuItem.submenu = submenu
    toolsMenu.addItem(buildSystemMenuItem)
    let tools = BuildSystemsManager.shared.buildSystems
    for tool in tools {
      let toolItem = NSMenuItem(title: tool.name, action: #selector(switchBuildSystem(_:)), keyEquivalent: "")
      toolItem.target = self
      toolItem.representedObject = tool
      submenu.addItem(toolItem)
    }
  }
  
  private func setupCommands() {
    let image = Bundle(for: BuildSystemPlugin.self).image(forResource: "run")?.imageWithTint(.darkGray)

    
    //This is an example of using builder but we can use simple constructor here
    let buildCommand = Command.builder(name: "Build", handler: executeBuild)
                              .menu(path: "Tools", keyEquivalent: "cmd+b")
                              .pushButtonToolbarItem(with: image!)
                              .build()
    CommandManager.shared.registerCommand(command: buildCommand)
  }
  
  func executeBuild() {
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildSystemsManager.shared.activeBuildSystem?.run(in: currentWorkbench)
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
