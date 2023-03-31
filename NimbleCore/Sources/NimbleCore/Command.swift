//
//  Command.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
  public let toolbarControlClass: CommandControl.Type?
  public let alignmentGroup: ToolbarAlignment?
  public let alignment: ToolbarAlignment

  // Grouping
  public fileprivate(set) weak var group: CommandGroup?

  public var groupIndex: Int? {
    group?.commands.firstIndex{$0 === self }
  }

  public init(name: String,
              menuPath: String? = nil,
              keyEquivalent: String? = nil,
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyboardShortcut = keyEquivalent.map{KeyboardShortcut($0)} ?? nil
    self.toolbarIcon = nil
    self.toolbarControlClass = nil
    self.alignment = .left(orderPriority: 100)
    self.handler = handler
    self.alignmentGroup = nil
  }

  public init(name: String,
              menuPath: String? = nil,
              keyEquivalent: String? = nil,
              toolbarIcon: NSImage?,
              alignmentGroup: ToolbarAlignment? = nil,
              alignment: ToolbarAlignment = .left(orderPriority: 100),
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyboardShortcut = keyEquivalent.map{KeyboardShortcut($0)} ?? nil
    self.toolbarIcon = toolbarIcon
    self.toolbarControlClass = nil
    self.alignment = alignment
    self.alignmentGroup = alignmentGroup
    self.handler = handler
  }

  public init(name: String,
              menuPath: String? = nil,
              keyEquivalent: String? = nil ,
              controlClass: CommandControl.Type?,
              alignmentGroup: ToolbarAlignment? = nil,
              alignment: ToolbarAlignment = .left(orderPriority: 100),
              handler: (@escaping Handler) = { _ in return } ) {

    self.name = name
    self.menuPath = menuPath
    self.keyboardShortcut = keyEquivalent.map{KeyboardShortcut($0)} ?? nil
    self.toolbarIcon = nil
    self.toolbarControlClass = controlClass
    self.alignment = alignment
    self.alignmentGroup = alignmentGroup
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
  public let menuPath: String?
  public let toolbarGroup: Bool

  open var alignment: ToolbarAlignment
  open var alignmentGroup: ToolbarAlignment?

  public var commands: [Command] {
    get { return _commands.compactMap{$0.value} }
    set {
      _commands = newValue.map {
        $0.group = self
        return WeakRef<Command>(value: $0)
      }
    }
  }

  // Create group using 'register' in the CommandManager to avoid leaks,
  // as commands are stored in groups by weak references
  fileprivate init(name: String,
                   menuPath: String?,
                   toolbarGroup: Bool,
                   alignmentGroup: ToolbarAlignment? = nil,
                   alignment: ToolbarAlignment,
                   commands: [Command]){

    self.name = name
    self.title = name
    self.menuPath = menuPath
    self.toolbarGroup = toolbarGroup
    self.alignmentGroup = alignmentGroup
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

  public func register(commands: [Command],
                       group: String,
                       menuPath: String? = nil,
                       toolbarGroup: Bool = true,
                       alignmentGroup: ToolbarAlignment? = nil,
                       alignment: ToolbarAlignment = .right(orderPriority: 100)) {

    let group = CommandGroup(name: group,
                             menuPath: menuPath,
                             toolbarGroup: toolbarGroup,
                             alignmentGroup: alignmentGroup,
                             alignment: alignment,
                             commands: commands)

    guard _groups[group.name] == nil else { return }

    commands.forEach { self.register(command: $0) }
    
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


  public enum Case {
    case left, center, right
  }

  public func `is`(_ `case`: Case) -> Bool {
    switch self {
    case .left:
      return `case` == .left
    case .center:
      return `case` == .center
    case .right:
      return `case` == .right
    }
  }
}

public protocol CommandControl where Self: NSControl {
  var workbench: Workbench? { get set }
}
