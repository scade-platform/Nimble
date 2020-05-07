//
//  Command.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 30/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa


open class Command {
  public typealias Handler = (Workbench) -> Void

  public struct State: OptionSet {
    public let rawValue: Int

    public init(rawValue: Self.RawValue) {
      self.rawValue = rawValue
    }
    public static let enabled = State(rawValue: 1 << 0)
    public static let selected = State(rawValue: 1 << 1)

    public static let `default`: State = [.enabled]
  }

  public let name: String

  // Menu item
  public let menuPath: String?
  public let keyEquivalent: String?
  
  // Toolbar item
  public let toolbarIcon: NSImage?
  public let toolbarView: NSView?

  // Actions
  private let handler: Handler

  public fileprivate(set) weak var group: CommandGroup?

  public var groupIndex: Int? { group?.commands.firstIndex{$0 === self } }

  open func run(in workbench: Workbench) {
    handler(workbench)
  }

  open func validate(in workbench: Workbench) -> State {
    return .default
  }

  public init(name: String,              
              menuPath: String? = nil,
              keyEquivalent: String? = nil ,
              toolbarIcon: NSImage? = nil,
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = toolbarIcon
    self.toolbarView = nil
    self.handler = handler
  }
  
  public init(name: String,
              menuPath: String? = nil,
              keyEquivalent: String? = nil ,
              view: NSView? = nil,
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.toolbarIcon = nil
    self.toolbarView = view
    self.handler = handler
  }
}

public class CommandGroup {
  private var _commands: [WeakRef<Command>] = []

  public let name: String
  public let title: String

  public var commands: [Command] {
    get { return _commands.compactMap{$0.value} }
    set {
      _commands = newValue.map {
        $0.group = self
        return WeakRef<Command>(value: $0)
      }
    }
  }

  public init(name: String, commands: [Command] = []){
    self.name = name
    self.title = name
    self.commands = commands
  }
}


public protocol CommandObserver {
  func commandDidRegister(_ command: Command)
  func commandGroupDidRegister(_ commandGroup: CommandGroup)
}


public extension CommandObserver {
  func commandDidRegister(_ command: Command) {}
  func commandGroupDidRegister(_ commandGroup: CommandGroup) {}
}


public class CommandManager {
  private var _groups: [String: CommandGroup] = [:]

  public private(set) var commands: [Command] = []
  public var groups: [CommandGroup] { Array(_groups.values) }

  public var observers = ObserverSet<CommandObserver>()

  private init() {}

  public func command(name: String) -> Command? {
    return commands.first{$0.name == name}
  }

  public func group(name: String) -> CommandGroup? {
    return _groups[name]
  }

  public func register(command: Command) {
    guard self.command(name: command.name) == nil else { return }
    commands.append(command)

    observers.notify {
      $0.commandDidRegister(command)
    }
  }

  public func register(commands: [Command]) {
    commands.forEach {self.register(command: $0)}
  }

  public func register(group: CommandGroup, registerCommands: Bool = true) {
    guard _groups[group.name] == nil else { return }

    if registerCommands {
      group.commands.forEach { self.register(command: $0) }
    }
    _groups[group.name] = group

    observers.notify {
      $0.commandGroupDidRegister(group)
    }
  }
}


public extension CommandManager {
  static let shared: CommandManager = CommandManager()
}


