//
//  ContextMenu.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 12/11/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

public protocol ContextMenuProvider {
  static func menuItems(for: File) -> [NSMenuItem]
  static func menuItems(for: Folder) -> [NSMenuItem]
  static func menuItems(for: Document) -> [NSMenuItem]
}

public extension ContextMenuProvider {
  //Default implementations
  static func menuItems(for: File) -> [NSMenuItem] {
    return []
  }
  
  static func menuItems(for: Folder) -> [NSMenuItem] {
    return []
  }
  
  static func menuItems(for: Document) -> [NSMenuItem] {
    return []
  }

  static func createMenuItem(title: String, selector: Selector?, for: Any? = nil) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: selector, keyEquivalent: "")
    menuItem.representedObject = `for`

    return menuItem
  }

  static func createSubMenuItem(title: String, items: [NSMenuItem]) -> NSMenuItem {
    let subMenuItem = NSMenu()
    items.forEach { subMenuItem.addItem($0) }

    let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    menuItem.submenu = subMenuItem

    return menuItem
  }
}

public final class ContextMenuManager {
  public static let shared = ContextMenuManager()
  private var providers: [ContextMenuProvider.Type] = []
  
  public func registerContextMenuProvider<T: ContextMenuProvider>(_ providerClass: T.Type) {
    providers.append(providerClass)
  }
  
  func menu(for item: Any) -> NSMenu {
    let menu = NSMenu()
    switch item {
    case let file as File:
      providers.flatMap{$0.menuItems(for: file)}.forEach{menu.addItem($0)}
      break
    case let folder as Folder:
      providers.flatMap{$0.menuItems(for: folder)}.forEach{menu.addItem($0)}
      break
    case let document as Document:
      providers.flatMap{$0.menuItems(for: document)}.forEach{menu.addItem($0)}
    default:
      break
    }
    return menu
  }
}

