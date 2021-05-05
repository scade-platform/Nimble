//
//  NSMenu.swift
//  NimbleCore
//
//  Created by Grigory Markin on 29.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public extension NSMenu {
  func findItem(with path: String) -> NSMenuItem? {
    let components = path.split(separator: "/")
    guard components.count > 0 else { return nil }
    
    let currentItem = item(withTitle: String(components[0]))
    if components.count == 1 {
      return currentItem
    } else {
      return currentItem?.submenu?.findItem(with: components[1...].joined(separator: "/"))
    }
  }

  func createMenu(for path: String) -> NSMenuItem? {
    var menu : NSMenu? = self
    var menuItem: NSMenuItem? = nil

    path.split(separator: "/").forEach {
      let title = String($0)
      if let item = menu?.item(withTitle: title) {
        menuItem = item
      } else {
        menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem?.submenu = NSMenu(title: title)
        menu?.addItem(menuItem!)
      }
      menu = menuItem?.submenu
    }

    return menuItem
  }
}
