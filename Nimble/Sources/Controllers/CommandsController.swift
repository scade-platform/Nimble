//
//  CommandsController.swift
//  Scade
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
    CommandManager.shared.register(commands: visibilityCommands)
  }
  
  private func createAreaVisibilityCommands() -> [Command] {
    let leftIcon = Bundle.main.loadBottonImage(name: "sidebar.left")
    let rightIcon = Bundle.main.loadBottonImage(name: "sidebar.right")
    return [
      ChangeAreaVisibility(title: "Navigator", icon: leftIcon, alignment: .left(orderPriority: 0)) { $0.navigatorArea },
      ChangeAreaVisibility(title: "Inspector", icon: rightIcon, alignment: .right(orderPriority: 0)) { $0.inspectorArea }
    ]
  }
  
  private func registerZoomCommands() {
    let commands = [
      ZoomCommand.create(name: "Actual Size", keyEquivalent: "cmd+0") { $0.zoomActualSize() },
      ZoomToFitCommand.create(name: "Zoom to Fit", keyEquivalent: "cmd+9") { $0.zoomToFit() },
      ZoomCommand.create(name: "Zoom In", keyEquivalent: "cmd+plus") { $0.zoomIn() },
      ZoomCommand.create(name: "Zoom Out", keyEquivalent: "cmd+minus") { $0.zoomOut() }
    ]

    CommandManager.shared.register(commands: commands, group: "Zoom", menuPath: "View", toolbarGroup: false)
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
