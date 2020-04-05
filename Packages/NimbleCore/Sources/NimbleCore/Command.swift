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
  private let handler: ((Command) -> Void)?
  
  //menu item
  public let menuPath: String?
  public let keyEquivalent: String?
  
  //toolbar item
  public let toolbarIcon: NSImage?
  
  public let groupName: String?
  
  @objc public func execute() {
    handler?(self)
  }

  public init(name: String, menuPath: String? = nil, keyEquivalent: String? = nil , toolbarIcon: NSImage? = nil, groupName: String? = nil, handler: @escaping (Command) -> Void) {
    self.name = name
    self.groupName = groupName
    self.handler = handler
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = toolbarIcon
  }
}

extension Command : Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
  
  public static func ==(lhs: Command, rhs: Command) -> Bool {
    return lhs.name == rhs.name
  }
}

public class CommandGroup {
  public let name: String
  
  public var palleteLable: String?
  private var weakCommands: [WeakRef<Command>] = []
  
  public var commands: [Command] {
    get {
      weakCommands = weakCommands.filter{$0.value != nil}
      return weakCommands.compactMap{$0.value}
    }
    set {
      weakCommands = newValue.map{WeakRef(value: $0)}
    }
  }
  
  public init(name: String){
    self.name = name
    self.palleteLable = name
  }
}

public class CommandState {
  public var isEnable: Bool {
    didSet {
      stateStorage?.stateDidChange?(self)
    }
  }
  
  public var title: String {
    didSet {
      stateStorage?.stateDidChange?(self)
    }
  }
  
  public var isSelected: Bool {
    didSet {
      stateStorage?.stateDidChange?(self)
    }
  }
    
  public weak var command: Command?
  
  public weak var stateStorage: CommandStateStorage?
  
  fileprivate init(command: Command, title: String = "", isEnable: Bool = true, isSelected: Bool = false, storage: CommandStateStorage) {
    self.command = command
    self.isEnable = isEnable
    self.isSelected = isSelected
    self.title = command.name
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
