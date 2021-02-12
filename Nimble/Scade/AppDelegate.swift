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
  static let themeMenuId = "themeMenu"
  static let settingsMenuId = "settingsMenu"
  
  static let openRecentProjectMenuId = "openRecentProjectMenu"
  static let openRecentDocumentMenuId = "openRecentDocumentMenu"
    
  // let settingsDocument = SettingsDocument()
  weak var settingsDocument: Document? = nil
  
  let documentController = NimbleController()
  
  @IBOutlet var fileMenu: NSMenu?
  @IBOutlet var newDocumentMenu: NSMenu?
  
  @IBOutlet var openRecentDocumentMenu: NSMenu?
  
  
  @objc private func newDocument(_ sender: Any?) {
    guard let docType = (sender as? NSMenuItem)?.representedObject as? CreatableDocument.Type else { return }
    documentController.makeDocument(ofType: docType)
  }
  
  @objc private func newProject(_ sender: Any?) {
    let wizardView = WizardView.loadFromNib()
    let wizard = WizardPanel(contentViewController: wizardView)
    wizard.styleMask = .borderless
    NSApp.runModal(for: wizard)
  }
  
  @objc private func switchTheme(_ item: NSMenuItem?) {
    ThemeManager.shared.selectedTheme = item?.representedObject as? Theme
  }
  
  @objc private func openSettings(_ sender: Any?) {
    guard let path = Settings.defaultPath else { return }
    
    if !path.exists {
      _ = try? path.touch()
    }
    
    guard let doc = DocumentManager.shared.open(path: path) else { return }
    
    doc.observers.add(observer: self)
    settingsDocument = doc
    
    if let content = Settings.shared.content.data(using: .utf8) {
      _ = try? doc.read(from: content, ofType: "public.text")
    }
        
    documentController.currentWorkbench?.open(doc, show: true)
    
    //documentController.openDocument(settingsDocument, display: true)
  }
    
  @objc private func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else { return true }
    
    switch item.identifier?.rawValue {
    case AppDelegate.themeMenuId:
      let itemTheme = item.representedObject as? Theme
      let currentTheme = ThemeManager.shared.selectedTheme
      item.state = (itemTheme === currentTheme) ? .on : .off
      
    default:
      break
    }
    
    return true
  }

  private func registerCommands() {
    let visibilityCommands = [
      ChangeAreaVisibility(title: "Navigator", icon: Bundle.main.loadBottonImage(name: "leftSideBar")) { $0.navigatorArea },
      ChangeAreaVisibility(title: "Debug area", icon: Bundle.main.loadBottonImage(name: "bottomArea")) { $0.debugArea },
      ChangeAreaVisibility(title: "Inspector", icon: Bundle.main.loadBottonImage(name: "rightSideBar")) { $0.inspectorArea }
    ]

    let visibilityGroup = CommandGroup(name: "AreaVisibilityCommands", commands: visibilityCommands)
    CommandManager.shared.register(group: visibilityGroup)

    ///TODO: move to the central place for common commands
    let zoomIn = Command(name: "Zoom In", keyEquivalent: "cmd+plus") { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomSupport else { return }
      editor.zoomIn()
    }

    let zoomOut = Command(name: "Zoom Out", keyEquivalent: "cmd+minus") { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomSupport else { return }
      editor.zoomOut()
    }

    CommandManager.shared.register(commands: [zoomIn, zoomOut])
  }

  private func setupApplicationMenu() {
    // Build newDocumentMenu
    var items: [NSMenuItem] = DocumentManager.shared.creatableDocuments.map {
      let item = NSMenuItem(title: $0.newMenuTitle, action: #selector(newDocument(_:)), keyEquivalent: "")
      item.keyEquivalent = $0.newMenuKeyEquivalent ?? ""
      item.target = self
      item.representedObject = $0
      return item
    }

    items.sort { $0.title < $1.title }

    // Enable if there are document creators
    fileMenu?.items.first?.isEnabled = !items.isEmpty
    
    if !WizardsManager.shared.wizards.isEmpty {
      let item = NSMenuItem(title: "New Project...", action: #selector(newProject(_:)), keyEquivalent: "n")
      item.keyEquivalentModifierMask = [.command, .shift]
      items.append(NSMenuItem.separator())
      items.append(item)
    }
    newDocumentMenu?.items = items
  }
  
  private func setupThemesMenu() {
    guard let themeMenu = NSApplication.shared.mainMenu?.findItem(with: "Scade/Preferences/Theme")?.submenu else { return }
        
    let defaultThemeItem = NSMenuItem(title: "Default", action: #selector(switchTheme(_:)), keyEquivalent: "")
    defaultThemeItem.target = self
    defaultThemeItem.identifier = NSUserInterfaceItemIdentifier(rawValue: AppDelegate.themeMenuId)
    
    var themeItems = [defaultThemeItem]
    
    func generateItems(for themes: [Theme]) {
      guard !themes.isEmpty else { return }
      themeItems.append(NSMenuItem.separator())

      for theme in themes {
        let themeItem = NSMenuItem(title: theme.name,
                                   action: #selector(self.switchTheme(_:)), keyEquivalent: "")
        themeItem.target = self
        themeItem.identifier = NSUserInterfaceItemIdentifier(rawValue: AppDelegate.themeMenuId)
        themeItem.representedObject = theme
        themeItems.append(themeItem)
      }
    }
    
    generateItems(for: ThemeManager.shared.defaultThemes)
    generateItems(for: ThemeManager.shared.userDefinedThemes)
    
    themeMenu.items = themeItems
  }
  
  private func setupSettingsMenu() {
    guard let settingsMenuItem = NSApplication.shared.mainMenu?.findItem(with: "Scade/Preferences/Settings") else { return }
    
    settingsMenuItem.target = self
    settingsMenuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: AppDelegate.settingsMenuId)
    settingsMenuItem.action = #selector(openSettings(_:))
  }
    
  private func setupCommandsMenus() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    for cmd in CommandManager.shared.commands {
      addMenuItem(for: cmd, into: mainMenu)
    }
    CommandManager.shared.observers.add(observer: self)
  }
  
  func addMenuItem(for command: Command, into menu: NSMenu) {
    guard let commandMenuItem = command.createMenuItem() else {
      return
    }
    if let mainMenuItem = menu.findItem(with: command.menuPath!)?.submenu {
      mainMenuItem.addItem(commandMenuItem)
    }
  }

  func applicationWillFinishLaunching(_ notification: Notification) {
    // Replace the default delegate installed by the NSDocumentController
    // The default one shows all recent documents without filtering etc.
    openRecentDocumentMenu?.delegate = self

    // Register workbench settings
    WorkbenchSettings.register()

    // Loading plugins
    PluginManager.shared.load()
    IconsManager.shared.register(provider: self)

    registerCommands()

    setupApplicationMenu()
    setupThemesMenu()
    setupSettingsMenu()
    setupCommandsMenus()
  }

  func applicationDidFinishLaunching(_ notification: Notification) {

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


// MARK: - DocumentObserver

extension AppDelegate: DocumentObserver {
  func documentDidSave(_ document: Document) {
    guard let doc = settingsDocument, doc === document else { return }
    Settings.shared.reload()
  }
}


// MARK: - CommandObserver

extension AppDelegate: CommandObserver {
  func commandDidRegister(_ command: Command) {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    self.addMenuItem(for: command, into: mainMenu)
  }
}
