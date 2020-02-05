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
  public let image: NSImage?
  
  @objc public func execute() {
    handler?()
  }
  
  public init(name: String, handler:  @escaping () -> Void, menuPath: String? = nil, keyEquivalent: String? = nil , image: NSImage? = nil) {
    self.name = name
    self.handler = handler
    self.menuPath = menuPath
    self.keyEquivalent = keyEquivalent
    self.image = image
  }
}

public extension Command {
  static func builder(name: String, handler: @escaping () -> Void) -> Builder {
    return Builder(name: name, handler: handler)
  }
  
  //Builder for commands with menu and toolbar items
  class Builder {
    private var name: String
    private var handler: () -> Void
    
    private var menuPath: String?
    private var keyEquivalent: String?
    
    private var image: NSImage?
    
    public init(name: String, handler:  @escaping () -> Void) {
      self.name = name
      self.handler = handler
    }
    
    public func menu(path: String, keyEquivalent: String? = nil) -> Builder {
      self.menuPath = path
      self.keyEquivalent = keyEquivalent
      return self
    }
    
    public func pushButtonToolbarItem(with image: NSImage) -> Builder {
      self.image = image
      return self
    }
    
    public func build() -> Command {
      let command = Command(name: name, handler: handler, menuPath: menuPath, keyEquivalent: keyEquivalent, image: image)
      return command
    }
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
