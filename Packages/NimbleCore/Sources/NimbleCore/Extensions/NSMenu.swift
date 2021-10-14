//
//  NSMenu.swift
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
