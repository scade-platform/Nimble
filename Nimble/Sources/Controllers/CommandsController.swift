//
//  CommandsController.swift
//  Scade
//
//  Created by Danil Kristalev on 18.08.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class CommandsController {
  
  private var mainMenu: NSMenu? {
    NSApp.mainMenu
  }
  
  private var commandGroups: [CommandGroup] {
    //Groups weakly store commands so there should be filtered to find non empty groups
    CommandManager.shared.groups.filter{ $0.commands.count > 0 }
  }
  
  private var commands: [Command] {
    //There are two type of command: with and without group.
    //Command in groups are handling separately
    //Here are looking for commands without a group
    CommandManager.shared.commands.filter{ $0.group == nil }
  }
  
  init() {
    registerCommands()
    setupCommandsMenus()
    
    CommandManager.shared.observers.add(observer: self)
  }
  
  
  // MARK: - Register new commands
  private func registerCommands() {
    registerAreaVisibilityCommands()
    registerZoomCommands()
  }
  
  private func registerAreaVisibilityCommands() {
    let visibilityCommands = createAreaVisibilityCommands()
    CommandManager.shared.register(commands: visibilityCommands, group: "AreaVisibilityCommands")
  }
  
  private func createAreaVisibilityCommands() -> [Command] {
    [
      ChangeAreaVisibility(title: "Navigator", icon: Bundle.main.loadBottonImage(name: "leftSideBar")) { $0.navigatorArea },
      ChangeAreaVisibility(title: "Debug area", icon: Bundle.main.loadBottonImage(name: "bottomArea")) { $0.debugArea },
      ChangeAreaVisibility(title: "Inspector", icon: Bundle.main.loadBottonImage(name: "rightSideBar")) { $0.inspectorArea }
    ]
  }
  
  private func registerZoomCommands() {
    let commands = [
      createZoomCommand(name: "Actual Size", keyEquivalent: "cmd+0") { $0.zoomActualSize() },
      createZoomCommand(name: "Zoom In", keyEquivalent: "cmd+plus") { $0.zoomIn() },
      createZoomCommand(name: "Zoom Out", keyEquivalent: "cmd+minus") { $0.zoomOut() }
    ]

    CommandManager.shared.register(commands: commands, group: "Zoom", menuPath: "View", toolbarGroup: false)
  }
  
  private func createZoomCommand(name: String , keyEquivalent: String, handler: @escaping (WorkbenchEditorZoomSupport) -> Void) -> Command {
    let zoomCommand = Command(name: name, keyEquivalent: keyEquivalent) { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomSupport else { return }
      handler(editor)
    }
    return zoomCommand
  }
  
  // MARK: - Commands menu
  
  private func setupCommandsMenus() {
    commandGroups.forEach{ addMenuItem(for: $0) }
    commands.forEach{ addMenuItem(for: $0) }
  }
  
  private func addMenuItem(for group: CommandGroup) {
    guard let menuPath = group.menuPath,
          let mainMenuItem = mainMenu?.createMenu(for: menuPath)?.submenu else { return }
    
    group.commands.forEach {
      mainMenuItem.addItem($0.createMenuItem())
    }
    mainMenuItem.addItem(.separator())
  }
  
  private func addMenuItem(for command: Command) {
    guard let menuPath = command.menuPath,
          let mainMenuItem = mainMenu?.createMenu(for: menuPath)?.submenu else { return }
    
    mainMenuItem.addItem(command.createMenuItem())
  }
  
}

// MARK: - CommandObserver

extension CommandsController: CommandObserver {
  func commandDidRegister(_ command: Command) {
    self.addMenuItem(for: command)
  }
  
  func commandGroupDidRegister(_ commandGroup: CommandGroup) {
    self.addMenuItem(for: commandGroup)
  }
}
