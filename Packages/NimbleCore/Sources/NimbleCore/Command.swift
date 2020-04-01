//
//  Command.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 30/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa


public class Command {
  
  public var observers = ObserverSet<CommandObserver>()
  
  public var isEnable: Bool {
    didSet {
      observers.notify {
        $0.commandDidChange(self)
      }
    }
  }
  
  public var name: String
  private let handler: ((Command) -> Void)?
  
  //menu item
  public let menuPath: String?
  public let keyEquivalent: String?
  
  //toolbar item
  public let toolbarIcon: NSImage?
  
  @objc public func execute() {
    guard isEnable else { return }
    handler?(self)
  }
  
  public init(name: String, menuPath: String? = nil, keyEquivalent: String? = nil , toolbarIcon: NSImage? = nil, isEnable: Bool = true, handler:  @escaping (Command) -> Void) {
    self.name = name
    self.handler = handler
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = toolbarIcon
    self.isEnable = isEnable
  }
}

public protocol CommandObserver: class {
  func commandDidChange(_ command: Command)
}

public class CommandManager {
  public static let shared: CommandManager = CommandManager()
  
  public var handlerRegisteredCommand : ((Command) -> Void)?
  
  private(set) public var commands: [Command] = []
  
  private init() {}
  
  public func registerCommand(command: Command) {
    guard !commands.contains(where: {$0.name == command.name}) else { return }
    commands.append(command)
    handlerRegisteredCommand?(command)
  }
}
