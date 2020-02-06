//
//  Command.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 30/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa


public class Command {
  public let name: String
  private let handler: (() -> Void)?
  
  //menu item
  public let menuPath: String?
  public let keyEquivalent: String?
  
  //toolbar item
  public let toolbarIcon: NSImage?
  
  @objc public func execute() {
    handler?()
  }
  
  public init(name: String, menuPath: String? = nil, keyEquivalent: String? = nil , toolbarIcon: NSImage? = nil, handler:  @escaping () -> Void) {
    self.name = name
    self.handler = handler
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = toolbarIcon
  }
}

public class CommandManager {
  public static let shared: CommandManager = CommandManager()
  
  private(set) public var commands: [Command] = []
  
  private init() {}
  
  public func registerCommand(command: Command) {
    commands.append(command)
  }
}
