//
//  Command.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 30/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

//MARK: - Command

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
    public static let disabled: State = []
  }

  // Actions
  private let handler: Handler

  public let name: String

  // Menu item
  public let menuPath: String?
  public let keyboardShortcut: KeyboardShortcut?
  
  // Toolbar item
  public let toolbarIcon: NSImage?
  public let toolbarControlClass: NSControl.Type?
  public let alignment: ToolbarAlignment

  public fileprivate(set) weak var group: CommandGroup?

  public var groupIndex: Int? {
    group?.commands.firstIndex{$0 === self }
  }

  public init(name: String,
              keyEquivalent: String? = nil ,
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = nil
    self.keyboardShortcut = keyEquivalent.map{KeyboardShortcut($0)} ?? nil
    self.toolbarIcon = nil
    self.toolbarControlClass = nil
    self.alignment = .left(orderPriority: 100)
    self.handler = handler
  }

  public init(name: String,              
              menuPath: String? = nil,
              keyEquivalent: String? = nil ,
              toolbarIcon: NSImage? = nil,
              alignment: ToolbarAlignment = .left(orderPriority: 100),
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyboardShortcut = keyEquivalent.map{KeyboardShortcut($0)} ?? nil
    self.toolbarIcon = toolbarIcon
    self.toolbarControlClass = nil
    self.alignment = alignment
    self.handler = handler
  }

  public init(name: String,
              menuPath: String? = nil,
              keyEquivalent: String? = nil ,
              controlClass: NSControl.Type? = nil,
              alignment: ToolbarAlignment = .left(orderPriority: 100),
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyboardShortcut = keyEquivalent.map{KeyboardShortcut($0)} ?? nil
    self.toolbarIcon = nil
    self.toolbarControlClass = controlClass
    self.alignment = alignment
    self.handler = handler
  }

  open func run(in workbench: Workbench) {
    handler(workbench)
  }

  open func validate(in workbench: Workbench) -> State {
    return .default
  }

  //Command doesn't contain concrete control but could produce it
  //so we need to ability to validate this concrete control
  open func validate(in workbench: Workbench, control: NSControl) -> State {
    return .default
  }

  public func enabled(in workbench: Workbench) -> Bool {
    return validate(in: workbench).contains(.enabled)
  }

  public func selected(in workbench: Workbench) -> Bool {
    return validate(in: workbench).contains(.selected)
  }
}

// MARK: - CommandGroup

public class CommandGroup {
  private var _commands: [WeakRef<Command>] = []

  public let name: String
  public let title: String
  
  open var alignment: ToolbarAlignment

  public var commands: [Command] {
    get { return _commands.compactMap{$0.value} }
    set {
      _commands = newValue.map {
        $0.group = self
        return WeakRef<Command>(value: $0)
      }
    }
  }

  public init(name: String, alignment: ToolbarAlignment =  .right(orderPriority: 100), commands: [Command] = []){
    self.name = name
    self.title = name
    self.alignment = alignment
    self.commands = commands
  }
}

// MARK: - CommandObserver

public protocol CommandObserver {
  func commandDidRegister(_ command: Command)
  func commandGroupDidRegister(_ commandGroup: CommandGroup)
}


public extension CommandObserver {
  func commandDidRegister(_ command: Command) {}
  func commandGroupDidRegister(_ commandGroup: CommandGroup) {}
}


// MARK: - CommandManager

public class CommandManager {
  public static let shared: CommandManager = CommandManager()

  private init() {}


  private var _groups: [String: WeakRef<CommandGroup>] = [:]
  private var _commands: [String: WeakRef<Command>] = [:]
  private var _shortcuts: [KeyboardShortcut: WeakRef<Command>] = [:]


  public private(set) var groups: [CommandGroup] = []
  public private(set) var commands: [Command] = []


  public var observers = ObserverSet<CommandObserver>()


  public func command(name: String) -> Command? {
    return _commands[name]?.value
  }

  public func command(shortcut: KeyboardShortcut) -> Command? {
    return _shortcuts[shortcut]?.value
  }

  public func group(name: String) -> CommandGroup? {
    return _groups[name]?.value
  }

  public func register(command: Command) {
    guard _commands[command.name] == nil else { return }

    commands.append(command)
    _commands[command.name] = WeakRef<Command>(value: command)

    if let shortcut = command.keyboardShortcut {
      _shortcuts[shortcut] = WeakRef<Command>(value: command)
    }

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
    
    groups.append(group)
    _groups[group.name] = WeakRef<CommandGroup>(value: group)

    observers.notify {
      $0.commandGroupDidRegister(group)
    }
  }
}



// MARK: - Utils

public enum ToolbarAlignment {
  //The higher the `orderPriority`, the more to the right the element
  case left(orderPriority: Int)
  
  //The higher the `orderPriority`, the more to the right the element
  case center(orderPriority: Int)
  
  //The higher the `orderPriority`, the more to the left the element
  case right(orderPriority: Int)
}
