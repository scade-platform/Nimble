//
//  Command.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 30/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

public protocol Command {
  var name: String { get }
  var delegate: CommandDelegate? { get set }
  func execute()
}

public protocol CommandDelegate {
  func menuItemPath(for command: Command) -> String?
  func menuItem(for command: Command) -> NSMenuItem?
  
  func toolbarItem(for command: Command) -> NSToolbarItem?
}

public extension CommandDelegate {
  func menuItemPath(for command: Command) -> String? {
    return nil
  }
  
  func menuItem(for command: Command) -> NSMenuItem? {
    return nil
  }
  
  func toolbarItem(for command: Command) -> NSToolbarItem? {
    return nil
  }
}

public class CommandManager {
  public static let shared: CommandManager = CommandManager()
  
  private var commands: [Command] = []
  
  private init() {}
  
  var toolbarItems: [NSToolbarItem] {
    var result : [NSToolbarItem] = []
    for command in commands {
      guard let delegate = command.delegate else { continue }
      if let toolbarItem = delegate.toolbarItem(for: command) {
        result.append(toolbarItem)
      }
    }
    return result
  }
  
  public func registerCommand(command: Command) {
    commands.append(command)
  }
  
  public func createCommand(name: String, handler: @escaping () -> Void) -> Command {
    return NimbleCommand(name: name, handler: handler)
  }
  
  func initMenu() {
    for command in commands {
      guard let delegate = command.delegate else { continue }
      if let commandMenuItem = delegate.menuItem(for: command) {
        guard let mainMenu = NSApplication.shared.mainMenu else { continue }
        let menuPath = delegate.menuItemPath(for: command) ?? ""
        if let mainMenuItem = mainMenu.findItem(with: menuPath)?.submenu {
          mainMenuItem.addItem(commandMenuItem)
        }
      }
    }
  }
  
}


class NimbleCommand : Command {
  var name: String
  var delegate: CommandDelegate?
  
  func execute() {
    handler?()
  }
  
  var handler: (() -> Void)?
  
  init(name: String, handler:  @escaping () -> Void) {
    self.name = name
    self.handler = handler
  }
}
