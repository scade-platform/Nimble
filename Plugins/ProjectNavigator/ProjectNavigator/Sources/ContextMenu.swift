//
//  ContextMenu.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 12/11/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

public final class ContextMenuManager {
  
  public static let shared = ContextMenuManager()
  
  private var menuItems : Set<NSMenuItem> = []
  private var subMenu: Set<NSMenu> = []
  private var subMenuBuilders: [ContextMenuBuilder] = []
  
}

extension ContextMenuManager {
  func extend(_ menu: NSMenu, for item : FileSystemElement) -> NSMenu {
    if !menuItems.isEmpty{
      menu.addItem(NSMenuItem.separator())
    }
    for item in menuItems {
      menu.addItem(item.copy() as! NSMenuItem)
    }
    if !subMenuBuilders.isEmpty {
      menu.addItem(NSMenuItem.separator())
    }
    for builder in subMenuBuilders {
      let subMenu = builder.build(for: item)
      let newMenuItem  = NSMenuItem(title: builder.title, action: nil, keyEquivalent: "")
      newMenuItem.submenu = subMenu.copy() as? NSMenu
      menu.addItem(newMenuItem)
    }
    if !subMenu.isEmpty {
      menu.addItem(NSMenuItem.separator())
    }
    for sm in subMenu {
      let newMenuItem  = NSMenuItem(title: sm.title, action: nil, keyEquivalent: "")
      newMenuItem.submenu = sm.copy() as? NSMenu
      menu.addItem(newMenuItem)
    }
    return menu
  }
}

public extension ContextMenuManager {
  func add(subMenu item: NSMenu) -> Bool {
    let result = subMenu.insert(item)
    return result.inserted
  }
  
  func add(menuItem: NSMenuItem) -> Bool {
    let result = menuItems.insert(menuItem)
    return result.inserted
  }
  
  func add(subMenuBuilder builder: ContextMenuBuilder) -> Bool {
    guard !subMenuBuilders.contains(where: {$0.title == builder.title}) else {
      return false
    }
    subMenuBuilders.append(builder)
    return true
  }
  
  func removeBy(title: String) -> Any? {
    if let menuItemIndex = menuItems.firstIndex(where: {$0.title == title}) {
      return menuItems.remove(at: menuItemIndex)
    } else if let subMenuIndex = subMenu.firstIndex(where: {$0.title == title}) {
      return subMenu.remove(at: subMenuIndex)
    } else if let subMenuBuilderIndex = subMenuBuilders.firstIndex(where: {$0.title == title}) {
      return subMenuBuilders.remove(at: subMenuBuilderIndex)
    }
    return nil
  }
}

public protocol ContextMenuBuilder {
  var title: String { get }
  func build(for fileSystemelement: FileSystemElement) -> NSMenu
}

