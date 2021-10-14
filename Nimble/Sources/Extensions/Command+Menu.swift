//
//  Command+Menu.swift
//  Nimble
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
import NimbleCore

extension Command {
  var menuItem: NSMenuItem? {
    guard let menuPath = self.menuPath ?? self.group?.menuPath,
          let menuItem = NSApp.mainMenu?.findItem(with: menuPath) else { return nil }
    
    return menuItem.submenu?.items.first{ ($0.representedObject as AnyObject?) === self }
  }

  func createMenuItem() -> NSMenuItem {
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

