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
    default:
      break
    }
    return menu
  }
}

