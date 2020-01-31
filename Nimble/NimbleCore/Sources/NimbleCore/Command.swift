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
  func menuItem(for command: Command) -> NSMenuItem?
  func toolbarItem(for command: Command) -> NSToolbarItem?
}

public class CommandManager {
  public static let shared: CommandManager = CommandManager()
  
  private var commands: [Command] = []
  
  private init() {}
  
  public func registerCommand(command: Command) {
    commands.append(command)
  }
  
  public func createCommand(name: String, handler: @escaping () -> Void) -> Command {
    return NimbleCommand(name: name, handler: handler)
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
