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
    if let menuItem = item as? NSMenuItem, let command = menuItem.representedObject as? Command {
      menuItem.title = command.title
      return command.isEnable
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

    //create for each new command ToolbarItem
    result.append(contentsOf: loadedCommands.map{$0.createToolbarItem()}.filter{$0.kind != .segment && $0.kind != .indefinite})
    
    result.append(.flexibleSpace)
    
    return result
  }
  
  func toolbarAllowedItems(_ toolbar: WorkbenchToolbar) -> [ToolbarItem] {
    var result : [ToolbarItem] = []
    let loadedCommands = CommandManager.shared.commands

    //create for each new command ToolbarItem
    result.append(contentsOf: loadedCommands.map{$0.createToolbarItem()}.filter{$0.kind != .segment && $0.kind != .indefinite})
    
    result.append(.flexibleSpace)
    result.append(.space)
    result.append(.separator)
    
    return result
  }
  
  func toolbarWillAddItem(_ toolbar: WorkbenchToolbar, item: ToolbarItem) {
    guard let win = toolbar.nsWindow, let workbench = win.windowController as? NimbleWorkbench else { return }
    if let command = item.command {
      command.observers.add(observer: workbench)
    }
  }
  
  func toolbarDidRemoveItem(_ toolbar: WorkbenchToolbar, item: ToolbarItem) {
    guard let win = toolbar.nsWindow, let workbench = win.windowController as? NimbleWorkbench else { return }
    if let command = item.command {
      command.observers.remove(observer: workbench)
    }
  }
}

extension CommandsToolbarDelegate: ToolbarItemDelegate {
  func isEnabled(_ toolbarItem: ToolbarItem) -> Bool {
    return toolbarItem.command?.isEnable ?? false
  }
}

extension CommandsToolbarDelegate: CommandObserver {
  func commandDidChange(_ command: Command) {
    
  }
}

fileprivate extension Command {
  func createToolbarItem() -> ToolbarItem {
    return ToolbarItem(identifier: NSToolbarItem.Identifier(rawValue: self.name),
                kind: self.kind,
                lable: self.name,
                palleteLable: self.name,
                image: self.toolbarIcon,
                width: 38.0,
                action:  #selector(self.execute),
                target: self,
                delegate: CommandsToolbarDelegate.shared)
  }
  
  var kind: ToolbarItemKind {
    if self.toolbarIcon != nil {
      return .imageButton
    } else {
      return .indefinite
    }
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
}
