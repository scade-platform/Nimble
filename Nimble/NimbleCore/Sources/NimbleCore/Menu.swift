//
//  Menu.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 16/10/2019.
//

import Cocoa

public class ContextMenuManager {
  
  public static let shared = ContextMenuManager()
  
  public private(set) var menuBuilders: [String : MenuBuilder] = [:]
  
  @discardableResult
  public func registerMenuBulder(id: String, builder: MenuBuilder) -> Bool {
    guard menuBuilders[id] == nil else {
      return false
    }
    menuBuilders[id] = builder
    return true
  }
}

public protocol MenuBuilder {
  func addSubMenu(builder: MenuBuilder, title: String) -> Bool
  
  func addSubMenu(menu: NSMenu, title: String) -> Bool
  
  func addItem(item: NSMenuItem) -> Bool

  func removeBy(title: String) -> AnyObject?
  
  func build(_ data: Any?) -> NSMenu
  
  func build() -> NSMenu
}

//default implementations
public extension MenuBuilder {
  func addSubMenu(builder: MenuBuilder, title: String) -> Bool {
    return false
  }
  
  func build() -> NSMenu {
    return build(nil)
  }
  
  func addSubMenu(menu: NSMenu, title: String) -> Bool {
    return false
  }
  
  func addItem(item: NSMenuItem) -> Bool {
    return false
  }
  
  func removeBy(title: String) -> AnyObject? {
    return nil
  }
  
}
