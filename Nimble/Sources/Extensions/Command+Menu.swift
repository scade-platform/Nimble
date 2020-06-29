//
//  Command+Menu.swift
//  Nimble
//
//  Created by Grigory Markin on 19.04.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

extension Command {
  var menuItem: NSMenuItem? {
    guard let menuPath = self.menuPath,
          let menuItem = NSApp.mainMenu?.findItem(with: menuPath) else { return nil }
    
    return menuItem.submenu?.items.first{ ($0.representedObject as AnyObject?) === self }
  }

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



extension Command {
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let workbench = NSApp.currentWorkbench else { return false }
    item?.title = self.name
    return validate(in: workbench).contains(.enabled)
  }
}


// MARK: - Utils

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
