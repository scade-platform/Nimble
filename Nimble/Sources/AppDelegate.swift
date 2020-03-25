//
//  AppDelegate.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  static let openRecentProjectMenuId = "openRecentProjectMenu"
  static let openRecentDocumentMenuId = "openRecentDocumentMenu"
  
  let documentController = NimbleController()
  
  @IBOutlet var fileMenu: NSMenu?
  @IBOutlet var newDocumentMenu: NSMenu?
  
  @IBOutlet var openRecentDocumentMenu: NSMenu?
  
  
  @objc private func newDocument(_ sender: Any?) {
    guard let docType = (sender as? NSMenuItem)?.representedObject as? CreatableDocument.Type else { return }
    documentController.makeUntitledDocument(ofType: docType)
  }
  
  @objc private func switchTheme(_ item: NSMenuItem?) {
    ThemeManager.shared.selectedTheme = item?.representedObject as? Theme
  }
    
  @objc private func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else { return true }
    
    switch item.representedObject {
    case is Theme, is Theme?:
      let itemTheme = item.representedObject as AnyObject?
      let currentTheme = ThemeManager.shared.selectedTheme
      item.state = (itemTheme === currentTheme) ? .on : .off
      
    default:
      break
    }
    
    return true
  }
  
  private func setupApplicationMenu() {
    // Build newDocumentMenu
    let items: [NSMenuItem] = DocumentManager.shared.creatableDocuments.map {
      let item = NSMenuItem(title: $0.newMenuTitle, action: #selector(newDocument(_:)), keyEquivalent: "")
      item.representedObject = $0
      return item
    }
    
    items.first?.keyEquivalent = "n"
    items.first?.keyEquivalentModifierMask = .command
    
    // Enable iff. there are document creators
    fileMenu?.items.first?.isEnabled = !items.isEmpty
    newDocumentMenu?.items = items
  }
      
  private func setupPreferencesMenu() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    guard let preferencesMenu = mainMenu.findItem(with: "Nimble/Preferences")?.submenu else { return }
    
    let colorThemeMenu = NSMenu(title: "Color Theme")
    let colorThemeMenuItem = NSMenuItem(title: "Color Theme", action: nil, keyEquivalent: "")
    colorThemeMenuItem.submenu = colorThemeMenu
    
    preferencesMenu.addItem(NSMenuItem.separator())
    preferencesMenu.addItem(colorThemeMenuItem)
    
    let defaultThemeItem = NSMenuItem(title: "Default", action: #selector(switchTheme(_:)), keyEquivalent: "")
    defaultThemeItem.target = self
    
    var themeItems = [defaultThemeItem]
    
    for theme in ThemeManager.shared.themes {
      let themeItem = NSMenuItem(title: theme.name, action: #selector(switchTheme(_:)), keyEquivalent: "")
      themeItem.target = self
      themeItem.representedObject = theme
      themeItems.append(themeItem)
    }
    
    colorThemeMenu.items = themeItems
  }
  
  private func setupCommandsMenus() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    for command in CommandManager.shared.commands {
      guard let commandMenuItem = createMenuItem(for: command) else {
        continue
      }
      if let mainMenuItem = mainMenu.findItem(with: command.menuPath!)?.submenu {
        mainMenuItem.addItem(commandMenuItem)
      }
    }
  }
  
  ///TODO: move it to the command (e.g. to an extension created in this module)
  private func createMenuItem(for command: Command) -> NSMenuItem? {
    guard command.menuPath != nil else { return nil }
    let (key, mask) = getKeyEquivalent(for: command)
    let menuItem = NSMenuItem(title: command.name, action: #selector(command.execute), keyEquivalent: key)
    menuItem.keyEquivalentModifierMask = mask
    menuItem.target = command
    menuItem.representedObject = command
    return menuItem
  }
  
  ///TODO: move it to the command (e.g. to an extension created in this module)
  private func getKeyEquivalent(for command: Command) -> (String, NSEvent.ModifierFlags) {
    guard let keyEquivalent = command.keyEquivalent else {
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
  
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Replace the default delegate installed by the NSDocumentController
    // The default one shows all recent documents without filtering etc.
    openRecentDocumentMenu?.delegate = self
    
    // Loading plugins
    PluginManager.shared.load()    
    IconsManager.shared.register(provider: self)

    setupApplicationMenu()
    setupPreferencesMenu()
    setupCommandsMenus()
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    
  }
    
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    documentController.open(url: URL(fileURLWithPath: filename))
    return true
  }
  
  
//  func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
//    //return true
//  }
  
}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
  func menuNeedsUpdate(_ menu: NSMenu) {
    switch menu.identifier?.rawValue {
    case .some(AppDelegate.openRecentDocumentMenuId), .some(AppDelegate.openRecentProjectMenuId):
      documentController.updateOpenRecentMenu(menu)
    default:
      return
    }
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


extension Command : NSUserInterfaceValidations {
  public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    if let menuItem = item as? NSMenuItem, let command = menuItem.representedObject as? Command {
      return command.isEnable
    }
    return true
  }
  
  
}
