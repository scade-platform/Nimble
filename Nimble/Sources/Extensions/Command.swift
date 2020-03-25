//
//  Command.swift
//  Nimble
//
//  Created by Danil Kristalev on 25/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import NimbleCore
import Cocoa

public extension Command {
  
  func createMenuItem() -> NSMenuItem? {
    guard menuPath != nil else { return nil }
    let (key, mask) = getKeyEquivalent()
    let menuItem = NSMenuItem(title: self.name, action: #selector(execute), keyEquivalent: key)
    menuItem.keyEquivalentModifierMask = mask
    menuItem.target = self
    menuItem.representedObject = self
    return menuItem
  }
  
  func getKeyEquivalent() -> (String, NSEvent.ModifierFlags) {
    guard let keyEquivalent = keyEquivalent else {
      return ("", [])
    }
    let char = keyEquivalent.last ?? Character("")
    var flags: NSEvent.ModifierFlags = []
    for flagCase in ModifierFlags.allCases {
      if keyEquivalent.lowercased().contains(flagCase.rawValue) {
        flags.insert(flagCase.flag)
      }
    }
    return (String(char), flags)
  }
}

extension Command : NSUserInterfaceValidations {
  public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    if let menuItem = item as? NSMenuItem, let command = menuItem.representedObject as? Command {
      menuItem.title = command.name
      return command.isEnable
    }
    return true
  }
}

fileprivate enum ModifierFlags: CaseIterable {
  case capsLock
  case shift
  case control
  case option
  case command
  case numericPad
  case help
  case function
  
  var rawValue: String {
    switch self {
    case .capsLock:
      return "capslock"
    case .shift:
      return "shift"
    case .control:
      return "ctrl"
    case .option:
      return "option"
    case .command:
      return "cmd"
    case .numericPad:
      return "num"
    case .help:
      return "help"
    case .function:
      return "fn"
    }
  }
  
  var flag: NSEvent.ModifierFlags {
    switch self {
    case .capsLock:
      return .capsLock
    case .shift:
      return .shift
    case .control:
      return .control
    case .option:
      return .option
    case .command:
      return .command
    case .numericPad:
      return .numericPad
    case .help:
      return .help
    case .function:
      return .function
    }
  }
}


// MARK: - IconsProvider

extension AppDelegate: IconsProvider {
  func icon<T>(for obj: T) -> Icon? {
    switch obj {
    case is File, is Document:
      return IconsManager.Icons.file
      
    case let folder as Folder:
      if folder.isRoot {
        return folder.isOpened ?  IconsManager.Icons.rootFolderOpened : IconsManager.Icons.rootFolder
      } else {
        return folder.isOpened ?  IconsManager.Icons.folderOpened : IconsManager.Icons.folder
      }
      
    default:
      return nil
    }
  }
}

