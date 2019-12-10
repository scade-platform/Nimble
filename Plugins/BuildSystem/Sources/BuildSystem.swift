//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 02/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import NimbleCore
import Cocoa

public final class BuildSystem: Module {
  public static var pluginClass: Plugin.Type = BuildSystemPlugin.self
}

public final class BuildSystemPlugin: Plugin {
  public init() {
    BuildToolsManager.shared.add(buildTool: ShellBuildTool())
    BuildToolsManager.shared.add(buildTool: SwiftBuildTool())
    setupMainMenu()
  }
  
  
  private func setupMainMenu() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    guard let toolsMenu = mainMenu.findItem(with: "Tools")?.submenu else { return }
    
    let buildSystemMenuItem = NSMenuItem(title: "Build System", action: nil, keyEquivalent: "")
    let submenu = NSMenu(title: "Build System")
    buildSystemMenuItem.submenu = submenu
    toolsMenu.addItem(buildSystemMenuItem)
    
    let autoItem = NSMenuItem(title: "Automatic", action: #selector(switchBuildTool(_:)), keyEquivalent: "")
    autoItem.target = self
    autoItem.representedObject = AutomaticBuildTool.shared
    submenu.addItem(autoItem)
    submenu.addItem(.separator())
    
    let tools = BuildToolsManager.shared.tools
    for tool in tools {
      let toolItem = NSMenuItem(title: tool.name, action: #selector(switchBuildTool(_:)), keyEquivalent: "")
      toolItem.target = self
      toolItem.representedObject = tool
      submenu.addItem(toolItem)
    }
    
    let buildMenuItem = NSMenuItem(title: "Build", action: #selector(executeBuild(_:)), keyEquivalent: "b")
    buildSystemMenuItem.keyEquivalentModifierMask = .command
    buildMenuItem.target = self
    toolsMenu.addItem(buildMenuItem)
  }
  
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else {return true}
    let itemTool = item.representedObject as AnyObject?
    let currentTool = BuildToolsManager.shared.selectedTool as AnyObject?
    item.state = (itemTool === currentTool) ? .on : .off
    return true
  }
  
  @objc func switchBuildTool(_ item: NSMenuItem?) {
    BuildToolsManager.shared.selectedTool = item?.representedObject as? BuildTool
  }
  
  @objc func executeBuild(_ item: NSMenuItem?) {
    //Workbench for active window
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildToolsManager.shared.selectedTool?.run(in: currentWorkbench)
  }
}
