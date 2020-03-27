//
//  Command.swift
//  Nimble
//
//  Created by Danil Kristalev on 30.03.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class CommandsToolbarDelegate: ToolbarDelegate {
  public static var shared = CommandsToolbarDelegate()
  
  func toolbarDefaultItems(_ toolbar: Toolbar) -> [ToolbarItem] {
    var result : [ToolbarItem] = []
    let loadedCommands = CommandManager.shared.commands

    //create for each new command ToolbarItem
    result.append(contentsOf: loadedCommands.map{$0.createToolbarItem()}.filter{$0.kind != .segment && $0.kind != .indefinite})
    
    result.append(.flexibleSpace)
    
    return result
  }
  
  func toolbarAllowedItems(_ toolbar: Toolbar) -> [ToolbarItem] {
    var result : [ToolbarItem] = []
    let loadedCommands = CommandManager.shared.commands

    //create for each new command ToolbarItem
    result.append(contentsOf: loadedCommands.map{$0.createToolbarItem()}.filter{$0.kind != .segment && $0.kind != .indefinite})
    
    result.append(.flexibleSpace)
    result.append(.space)
    result.append(.separator)
    
    return result
  }
  
  func toolbarWillAddItem(_ toolbar: Toolbar, item: ToolbarItem) {
    guard let win = toolbar.nsWindow, let workbench = win.windowController as? NimbleWorkbench else { return }
    if let command = item.command {
      command.observers.add(observer: workbench)
    }
  }
  
  func toolbarDidRemoveItem(_ toolbar: Toolbar, item: ToolbarItem) {
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
