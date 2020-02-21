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
  private var stopCommand: Command? = nil
  private var currentProcess: Process?
    
  func load() {
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
    let runImage = Bundle(for: BuildSystemPlugin.self).image(forResource: "run")?.imageWithTint(.darkGray)
    let stopImage = Bundle(for: BuildSystemPlugin.self).image(forResource: "stop")?.imageWithTint(.darkGray)

    let runCommand = Command(name: "Run", menuPath: "Tools", keyEquivalent: "cmd+r", toolbarIcon: runImage) { self.run() }
    CommandManager.shared.registerCommand(command: runCommand)
    stopCommand = Command(name: "Stop", menuPath: "Tools", keyEquivalent: "cmd+.", toolbarIcon: stopImage, isEnable: false) { self.stop() }
    CommandManager.shared.registerCommand(command: stopCommand!)
    let claenCommand = Command(name: "Clean", menuPath: "Tools", keyEquivalent: "cmd+K") { self.clean() }
    CommandManager.shared.registerCommand(command: claenCommand)
    let buildCommand = Command(name: "Build", menuPath: "Tools", keyEquivalent: "cmd+b") { self.build() }
    CommandManager.shared.registerCommand(command: buildCommand)
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
  
  func build() {
    //Workbench for active window
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildSystemsManager.shared.activeBuildSystem?.run(in: currentWorkbench)
  }
  
  func run() {
    //Workbench for active window
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildSystemsManager.shared.activeBuildSystem?.launcher?.launch(in: currentWorkbench, handler: launcherHandler(status:process:))
  }
  
  func clean() {
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildSystemsManager.shared.activeBuildSystem?.clean(in: currentWorkbench)
  }
  
  func launcherHandler(status: BuildStatus, process: Process?) -> Void {
    guard let process = process else {
      stopCommand?.isEnable = false
      return
    }
    if status == .running && process.isRunning {
      stopCommand?.isEnable = true
      currentProcess = process
    } else {
      stopCommand?.isEnable = false
      currentProcess = nil
    }
  }
  
  func stop() {
    guard let process = currentProcess else { return }
    if process.isRunning {
      process.terminate()
    }
  }
}
