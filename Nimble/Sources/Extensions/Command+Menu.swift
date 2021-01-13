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
    let (key, mask) = keyboardShortcut?.keyEquivalent ?? ("", [])
    let menuItem = NSMenuItem(title: self.name, action: #selector(execute), keyEquivalent: key)

    menuItem.keyEquivalentModifierMask = mask
    menuItem.target = self
    menuItem.representedObject = self

    return menuItem
  }

  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let workbench = NSApp.currentWorkbench else { return false }
    item?.title = self.name
    return validate(in: workbench).contains(.enabled)
  }
}

