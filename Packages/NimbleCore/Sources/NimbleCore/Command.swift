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
  func commandDidChange(_ command: Command)
}

extension Command : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
  
  public static func ==(lhs: Command, rhs: Command) -> Bool {
    return lhs.name == rhs.name
  }
}

public class CommandState {
  public var isEnable: Bool {
    didSet {
      stateStorage?.stateDidChange?(self)
    }
  }
  
  public weak var command: Command?
  
  public weak var stateStorage: CommandStateStorage?
  
  fileprivate init(command: Command, isEnable: Bool = true, storage: CommandStateStorage) {
    self.command = command
    self.isEnable = isEnable
    self.stateStorage = storage
  }
}

public class CommandStateStorage {
  private var states: [CommandState] = []
  fileprivate let stateDidChange: ((CommandState) -> Void)?
  
  public init(_ stateDidChange: ((CommandState) -> Void)?) {
    self.stateDidChange = stateDidChange
  }
}

public extension CommandStateStorage {
  subscript(command: Command) -> CommandState? {
    //remove all states for released commands
    self.states = states.filter{$0.command != nil}
    
    if let state = states.first(where: {$0.command == command}){
      return state
    } else {
      //command hasn't been registred or release
      guard let command = CommandManager.shared.commands.first(where: {$0 == command}) else { return nil }
      
      let commandState = CommandState(command: command, storage: self)
      states.append(commandState)
      return commandState
    }
  }
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
