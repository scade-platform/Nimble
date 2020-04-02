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
  
  public var isSelected: Bool {
    didSet {
      observers.notify {
        $0.commandDidChange(self)
      }
    }
  }
  
  public let name: String
  public var title: String
  private let handler: (() -> Void)?
  
  //menu item
  public let menuPath: String?
  public let keyEquivalent: String?
  
  //toolbar item
  public let toolbarIcon: NSImage?
  
  public var groupName: String?
  
  @objc public func execute() {
    guard isEnable else { return }
    handler?()
  }
  
  public init(name: String, menuPath: String? = nil, keyEquivalent: String? = nil , toolbarIcon: NSImage? = nil, handler:  @escaping () -> Void) {
    self.name = name
    self.title = name
    self.groupName = nil
    self.handler = handler
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = toolbarIcon
    self.isEnable = true
    self.isSelected = false
  }
}

public class CommandGroup {
  public let name: String
  
  public var palleteLable: String?
  public var commands: [WeakRef<Command>] = []
  
  public init(name: String){
    self.name = name
    self.palleteLable = name
  }
}

public protocol CommandObserver: class {
  func commandDidChange(_ command: Command)
}

public class CommandManager {
  public static let shared: CommandManager = CommandManager()
  
  public var handlerRegisteredCommand : ((Command) -> Void)?
  
  private(set) public var commands: [Command] = []
  private(set) public var groups: [String: CommandGroup] = [:]
  
  private init() {}
  
  public func registerCommand(command: Command) {
    guard !commands.contains(where: {$0.name == command.name}) else { return }
    commands.append(command)
    handlerRegisteredCommand?(command)
  }
  
  public func registerGroup(group: CommandGroup) {
    guard groups[group.name] == nil else { return }
    groups[group.name] = group
  }
}
