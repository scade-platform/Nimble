//
//  Command.swift
//  Nimble
//
//  Created by Danil Kristalev on 25/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import NimbleCore
import Cocoa

public extension Command {
  
  func createMenuItem() -> NSMenuItem? {
    guard menuPath != nil else { return nil }
    let (key, mask) = getKeyEquivalent()
    let menuItem = NSMenuItem(title: self.name, action: #selector(execute), keyEquivalent: key)
    menuItem.keyEquivalentModifierMask = mask
    menuItem.target = self
    menuItem.representedObject = self
    return menuItem
  }
  
  func getKeyEquivalent() -> (String, NSEvent.ModifierFlags) {
    guard let keyEquivalent = keyEquivalent else {
      return ("", [])
    }
    let char = keyEquivalent.last ?? Character("")
    var flags: NSEvent.ModifierFlags = []
    for flagCase in ModifierFlags.allCases {
      if keyEquivalent.lowercased().contains(flagCase.rawValue) {
        flags.insert(flagCase.flag)
      }
    }
    return (String(char), flags)
  }
}

extension Command : NSUserInterfaceValidations {
  public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let workbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench else { return false }
    if let menuItem = item as? NSMenuItem, let command = menuItem.representedObject as? Command {
      
      menuItem.title = workbench.commandSates[command]?.title ?? ""
      return workbench.commandSates[command]?.isEnable ?? false
    }
    return true
  }
}

fileprivate enum ModifierFlags: CaseIterable {
  case capsLock
  case shift
  case control
  case option
  case command
  case numericPad
  case help
  case function
  
  var rawValue: String {
    switch self {
    case .capsLock:
      return "capslock"
    case .shift:
      return "shift"
    case .control:
      return "ctrl"
    case .option:
      return "option"
    case .command:
      return "cmd"
    case .numericPad:
      return "num"
    case .help:
      return "help"
    case .function:
      return "fn"
    }
  }
  
  var flag: NSEvent.ModifierFlags {
    switch self {
    case .capsLock:
      return .capsLock
    case .shift:
      return .shift
    case .control:
      return .control
    case .option:
      return .option
    case .command:
      return .command
    case .numericPad:
      return .numericPad
    case .help:
      return .help
    case .function:
      return .function
    }
  }
}

class CommandsToolbarDelegate: ToolbarDelegate {
  public static var shared = CommandsToolbarDelegate()
  
  func toolbarDefaultItems(_ toolbar: WorkbenchToolbar) -> [ToolbarItem] {
    var result : [ToolbarItem] = []
    let loadedCommands = CommandManager.shared.commands

    //create for each command ToolbarItem
    result.append(contentsOf: loadedCommands.map{$0.createToolbarItem(toolbar)}.filter{$0.kind != .segment && $0.kind != .indefinite})
    
    result.append(.flexibleSpace)
    
    //find all groups
    let loadedGroups = CommandManager.shared.groups
    result.append(contentsOf: loadedGroups.map{$0.value.createToolbarItem(toolbar)})
    
    return result
  }
  
  func toolbarAllowedItems(_ toolbar: WorkbenchToolbar) -> [ToolbarItem] {
    var result : [ToolbarItem] = []
    let loadedCommands = CommandManager.shared.commands

    //create for each new command ToolbarItem
    result.append(contentsOf: loadedCommands.map{$0.createToolbarItem(toolbar)}.filter{$0.kind != .segment && $0.kind != .indefinite})
    
    //find all new groups
    let loadedGroups = CommandManager.shared.groups
    result.append(contentsOf: loadedGroups.map{$0.value.createToolbarItem(toolbar)})
    
    result.append(.flexibleSpace)
    result.append(.space)
    result.append(.separator)
    
    return result
  }
  
  func toolbarWillAddItem(_ toolbar: WorkbenchToolbar, item: ToolbarItem) {
    //nothing
  }
  
  func toolbarDidRemoveItem(_ toolbar: WorkbenchToolbar, item: ToolbarItem) {
    //nothing
  }
}

extension CommandsToolbarDelegate: ToolbarItemDelegate {
  func isEnabled(_ toolbarItem: ToolbarItem) -> Bool {
    guard let workbench = toolbarItem.toolbar?.nsWindow?.windowController as? Workbench, let command = toolbarItem.command else { return true }
    return workbench.commandSates[command]?.isEnable ?? false
  }
  
  func isSelected(_ toolbarItem: ToolbarItem) -> Bool {
    guard let workbench = toolbarItem.toolbar?.nsWindow?.windowController as? Workbench, let command = toolbarItem.command else { return true }
    return workbench.commandSates[command]?.isSelected ?? false
  }
}

fileprivate extension Command {
  func createToolbarItem(_ toolbar: WorkbenchToolbar? = nil) -> ToolbarItem {
    return ToolbarItem(identifier: NSToolbarItem.Identifier(rawValue: self.name),
                kind: self.kind,
                lable: "",
                palleteLable: "",
                image: self.toolbarIcon,
                width: 38.0,
                action:  #selector(self.execute),
                target: self,
                toolbar: toolbar,
                delegate: CommandsToolbarDelegate.shared)
  }
  
  var kind: ToolbarItemKind {
    if self.groupName != nil {
      return .segment
    } else if self.toolbarIcon != nil {
      return .imageButton
    } else {
      return .indefinite
    }
  }
}

fileprivate extension CommandGroup {
  func createToolbarItem(_ toolbar: WorkbenchToolbar? = nil) -> ToolbarItem {
    let toolbarSubitems = self.commands.map{$0.createToolbarItem(toolbar)}
    
    return ToolbarItem(identifier: NSToolbarItem.Identifier(rawValue: self.name),
                   kind: .segmentedControl,
                   palleteLable: self.palleteLable ?? "",
                   group: toolbarSubitems,
                   toolbar: toolbar,
                   delegate: CommandsToolbarDelegate.shared)
  }
}

fileprivate extension ToolbarItem {
  var command: Command? {
    guard group.isEmpty else {return nil}
    if let c = CommandManager.shared.commands.filter({$0.name == self.identifier.rawValue}).first {
      return c
    }
    return nil
  }
  
  var commandGroup: CommandGroup? {
    guard !group.isEmpty else {return nil}
    if let g = CommandManager.shared.groups.filter({$0.key == self.identifier.rawValue}).first {
      return g.value
    }
    return nil
  }
}


class NimbleWorkbenchCommands {
  static let shared = NimbleWorkbenchCommands()
  
  let workbenchAreaGroup = CommandGroup(name: "WorkbenchAreaGroup")
  
  weak var navigatorAreaCommand: Command?
  weak var debugAreaCommand: Command?
  weak var inspectorAreaCommand: Command?
  
  init() {
    CommandManager.shared.registerGroup(group: workbenchAreaGroup)
  }
  
  
  func registerCommands() {
    //Command to show/hide Navigator Area
    if navigatorAreaCommand == nil {
      let name: String = "NavigatorAreaCommand"
      
      let changeNavigatorAreaVisabilityCommand = Command(name: name, menuPath: "View", keyEquivalent: nil, toolbarIcon: NavigatorView.icon, groupName: workbenchAreaGroup.name) { command in
        guard let workbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? NimbleWorkbench, let navigatorArea = workbench.navigatorArea else { return }
        let title = navigatorArea.isHidden  ? "Hide Navigator Area" : "Show Navigator Area"
         workbench.commandSates[command]?.title = title
        navigatorArea.isHidden = !navigatorArea.isHidden
      }
      
      navigatorAreaCommand = changeNavigatorAreaVisabilityCommand
      CommandManager.shared.registerCommand(command: changeNavigatorAreaVisabilityCommand)
      workbenchAreaGroup.commands.append(changeNavigatorAreaVisabilityCommand)
    }
    
    //Command to show/hide Debug Area
    if debugAreaCommand == nil {
      let name: String = "DegubAreaCommand"
      
      let changeDebugAreaVisabilityCommand = Command(name: name, menuPath: "View", keyEquivalent: nil, toolbarIcon: DebugView.icon, groupName: workbenchAreaGroup.name) { command in
        guard let workbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? NimbleWorkbench, let debugArea = workbench.debugArea else { return }
        let title = debugArea.isHidden ? "Hide Debug Area" : "Show Debug Area"
        workbench.commandSates[command]?.title = title
        debugArea.isHidden = !debugArea.isHidden
      }
      
      debugAreaCommand = changeDebugAreaVisabilityCommand
      CommandManager.shared.registerCommand(command: changeDebugAreaVisabilityCommand)
      workbenchAreaGroup.commands.append(changeDebugAreaVisabilityCommand)
    }
    
    //Command to show/hide Inspector Area
    if inspectorAreaCommand == nil {
      let name = "InspectorAreaCommand"
      
      let changeInspectorAreaVisabilityCommand = Command(name: name, menuPath: "View", keyEquivalent: nil, toolbarIcon: InspectorView.icon, groupName: workbenchAreaGroup.name) { command in
        guard let workbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? NimbleWorkbench, let inspectorArea = workbench.inspectorArea else { return }
        let title = inspectorArea.isHidden ? "Hide Inspector Area" :  "Show Inspector Area"
        workbench.commandSates[command]?.title = title
        inspectorArea.isHidden = !inspectorArea.isHidden
      }
      inspectorAreaCommand = changeInspectorAreaVisabilityCommand
      CommandManager.shared.registerCommand(command: changeInspectorAreaVisabilityCommand)
      workbenchAreaGroup.commands.append(changeInspectorAreaVisabilityCommand)
    }
  }
  
  func initCommandStates(for workbench: NimbleWorkbench) {
    //Navigator Area
    if let navigatorArea = workbench.navigatorArea, let command = navigatorAreaCommand {
      let title: String = navigatorArea.isHidden ? "Show Navigator Area" : "Hide Navigator Area"
      
      workbench.commandSates[command]?.isSelected = !navigatorArea.isHidden
      workbench.commandSates[command]?.title = title
    }
    //Debug Area
    if let debugArea = workbench.debugArea, let command = debugAreaCommand {
      let title = debugArea.isHidden ? "Show Debug Area" : "Hide Debug Area"
      
      workbench.commandSates[command]?.isSelected = !debugArea.isHidden
      workbench.commandSates[command]?.title = title
    }
    //Inspector Area
    if let inspectorArea = workbench.inspectorArea, let command = inspectorAreaCommand {
      let title = inspectorArea.isHidden ? "Show Inspector Area" : "Hide Inspector Area"
      
      workbench.commandSates[command]?.isSelected = !inspectorArea.isHidden
      workbench.commandSates[command]?.title = title
    }
  }
  
}
