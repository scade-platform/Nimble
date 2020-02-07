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
        $0.enableDidChange(self)
      }
    }
  }
  
  public let name: String
  private let handler: (() -> Void)?
  
  //menu item
  public let menuPath: String?
  public let keyEquivalent: String?
  
  //toolbar item
  public let toolbarIcon: NSImage?
  
  @objc public func execute() {
    guard isEnable else { return }
    handler?()
  }
  
  public init(name: String, menuPath: String? = nil, keyEquivalent: String? = nil , toolbarIcon: NSImage? = nil, isEnable: Bool = true, handler:  @escaping () -> Void) {
    self.name = name
    self.handler = handler
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = toolbarIcon
    self.isEnable = isEnable
  }
}

public protocol CommandObserver: class {
  func enableDidChange(_ command: Command)
}

public class CommandManager {
  public static let shared: CommandManager = CommandManager()
  
  private(set) public var commands: [Command] = []
  
  private init() {}
  
  public func registerCommand(command: Command) {
    guard !commands.contains(where: {$0.name == command.name}) else { return }
    commands.append(command)
  }
}
