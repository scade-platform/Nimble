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
  private weak var runCommand: Command?
  private weak var buildCommand: Command?
  private weak var stopCommand: Command?
  private var currentProcess: Process?
  
  func load() {
    BuildSystemsManager.shared.add(buildSystem: SwiftBuildSystem())
    BuildSystemsManager.shared.add(buildSystem: SPMBuildSystem())
    setupMainMenu()
    setupCommands()
  }
  
  func activate(in workbench: Workbench) {
    guard let stopCommand = stopCommand else {
      return
    }
    workbench.commandSates[stopCommand]?.isEnable = false
  }
  
  private func setupMainMenu() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    guard let toolsMenu = mainMenu.findItem(with: "Tools")?.submenu else { return }
    
    let buildSystemMenuItem = NSMenuItem(title: "Build System", action: nil, keyEquivalent: "")
    let submenu = NSMenu(title: "Build System")
    buildSystemMenuItem.submenu = submenu
    toolsMenu.addItem(buildSystemMenuItem)
    
    let autoItem = NSMenuItem(title: "Automatic", action: #selector(switchBuildSystem(_:)), keyEquivalent: "")
    autoItem.target = self
    autoItem.representedObject = Automatic.shared
    submenu.addItem(autoItem)
    submenu.addItem(.separator())

    let tools = BuildSystemsManager.shared.buildSystems
    for tool in tools {
      let toolItem = NSMenuItem(title: tool.name, action: #selector(switchBuildSystem(_:)), keyEquivalent: "")
      toolItem.target = self
      toolItem.representedObject = tool
      submenu.addItem(toolItem)
    }
  }
  
  private func setupCommands() {
    let buttonIconColor = getColorFromAsset("ButtonIconColor", defualt: .darkGray)
    let runImage = Bundle(for: BuildSystemPlugin.self).image(forResource: "run")?.imageWithTint(buttonIconColor)
    let stopImage = Bundle(for: BuildSystemPlugin.self).image(forResource: "stop")?.imageWithTint(buttonIconColor)

    let runCommand = Command(name: "Run", menuPath: "Tools", keyEquivalent: "cmd+r", toolbarIcon: runImage) { _ in self.run() }
    CommandManager.shared.registerCommand(command: runCommand)
    self.runCommand = runCommand
    
    let stopCommand = Command(name: "Stop", menuPath: "Tools", keyEquivalent: "cmd+.", toolbarIcon: stopImage) { _ in self.stop() }
    CommandManager.shared.registerCommand(command: stopCommand)
    self.stopCommand = stopCommand
    
    let claenCommand = Command(name: "Clean", menuPath: "Tools", keyEquivalent: "cmd+K") { _ in self.clean() }
    CommandManager.shared.registerCommand(command: claenCommand)
    
    let buildCommand = Command(name: "Build", menuPath: "Tools", keyEquivalent: "cmd+b") { _ in self.build() }
    CommandManager.shared.registerCommand(command: buildCommand)
    self.buildCommand = buildCommand
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
    
    showConsoleTillFirstEscPress(in: currentWorkbench)
    
    BuildSystemsManager.shared.activeBuildSystem?.run(in: currentWorkbench, handler: { [weak self] status, process in
      self?.launcherHandler(status: status, process: process, workbench: currentWorkbench)
    })
  }
  
  func run() {
    //Workbench for active window
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    
    showConsoleTillFirstEscPress(in: currentWorkbench)
    
    BuildSystemsManager.shared.activeBuildSystem?.run(in: currentWorkbench) { [weak self] status, process in
      switch status {
      case .finished:
        DispatchQueue.main.async { [weak self] in
          self?.showConsoleTillFirstEscPress(in: currentWorkbench)
          BuildSystemsManager.shared.activeBuildSystem?.launcher?.launch(in: currentWorkbench, handler: { status, process in
            self?.launcherHandler(status: status,process: process, workbench: currentWorkbench)
          })
        }
      case .failed, .running:
        self?.launcherHandler(status: status,process: process, workbench: currentWorkbench)
      }
    }
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
  
  func clean() {
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    BuildSystemsManager.shared.activeBuildSystem?.clean(in: currentWorkbench)
  }
  
  func launcherHandler(status: BuildStatus, process: Process?, workbench: Workbench) -> Void {
    guard let runCommand = runCommand, let buildCommand = buildCommand, let stopCommand = stopCommand else { return }
    guard let process = process else {
      workbench.commandSates[runCommand]?.isEnable = true
      workbench.commandSates[buildCommand]?.isEnable = true
      workbench.commandSates[stopCommand]?.isEnable = false
      return
    }
    if status == .running && process.isRunning {
      workbench.commandSates[runCommand]?.isEnable = false
      workbench.commandSates[buildCommand]?.isEnable = false
      workbench.commandSates[stopCommand]?.isEnable = true
      currentProcess = process
    } else {
      workbench.commandSates[runCommand]?.isEnable = true
      workbench.commandSates[buildCommand]?.isEnable = true
      workbench.commandSates[stopCommand]?.isEnable = false
      currentProcess = nil
    }
  }
  
  func stop() {
    guard let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return }
    
    guard let process = currentProcess else { return }
    if process.isRunning {
      process.terminate()
    }
    showConsoleTillFirstEscPress(in: currentWorkbench)
  }
  
  fileprivate func getColorFromAsset(_ name: String, defualt: NSColor) -> NSColor {
     return NSColor.init(named: name, bundle: Bundle.init(for: BuildSystemPlugin.self)) ?? defualt
  }
}
