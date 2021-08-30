//
//  ContentViewController.swift
//  Scade
//
//  Created by Danil Kristalev on 19.07.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class WorkbenchContentView: NSView, WorkbenchView {

  public override func performKeyEquivalent(with event: NSEvent) -> Bool {
    guard let shortcut = event.keyboardShortcut,
          let cmd = CommandManager.shared.command(shortcut: shortcut),
          let workbench = self.workbench, cmd.enabled(in: workbench) else { return super.performKeyEquivalent(with: event) }

    cmd.run(in: workbench)
    return true
  }
  
}

class WorkbenchContentViewController: NSViewController, WorkbenchViewController {
  
  private var themeMenuId: NSUserInterfaceItemIdentifier {
    NSUserInterfaceItemIdentifier(rawValue: "themeMenu")
  }
  
  var documentController: NimbleController? {
    NSDocumentController.shared as? NimbleController
  }
  
  @MainMenuItem("File/New")
  private var newDocumentMenuItem: NSMenuItem?
  
  @MainMenuItem(.appName/"Preferences/Theme")
  private var themeMenuItem: NSMenuItem?
  
  @MainMenuItem(.appName/"Preferences/Settings")
  private var settingsMenuItem: NSMenuItem?
  
  private var newDocumentMenu: NSMenu? {
    newDocumentMenuItem?.submenu
  }
  
  private var themeMenu: NSMenu? {
    themeMenuItem?.submenu
  }
  
  //Utility computed property for creation new menu separator after each usage
  private var menuSeporator: [NSMenuItem] {
    [NSMenuItem.separator()]
  }
  
  var settingsController: SettingsController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupApplicationMenu()
    settingsController = SettingsController()
  }
  
  private func setupApplicationMenu(){
    setupNewDocumentMenu()
    setupThemesMenu()
    setupSettingsMenu()
  }
  
  private func setupNewDocumentMenu() {
    let newDocumentMenuItems = createNewDocumentMenuItems()
    newDocumentMenuItem?.isEnabled = !newDocumentMenuItems.isEmpty
    newDocumentMenu?.items = newDocumentMenuItems
  }
  
  private func createNewDocumentMenuItems() -> [NSMenuItem] {
    let documentItems = createDocumentTypeMenuItems()
    let newProjectWizardItem = createProjectWizardMenuItem()
    
    return documentItems + menuSeporator + newProjectWizardItem
  }
  
  private func createDocumentTypeMenuItems() -> [NSMenuItem] {
    var items: [NSMenuItem] = DocumentManager.shared.creatableDocuments.map {
      let item = NSMenuItem(title: $0.newMenuTitle, action: #selector(newDocument(_:)), keyEquivalent: "")
      item.keyEquivalent = $0.newMenuKeyEquivalent ?? ""
      item.target = self
      item.representedObject = $0
      return item
    }

    items.sort { $0.title < $1.title }
    
    return items
  }
  
  private func createProjectWizardMenuItem() -> [NSMenuItem] {
    guard !WizardsManager.shared.wizards.isEmpty else {
      return []
    }
    
    let item = NSMenuItem(title: "New Project...", action: #selector(newProject(_:)), keyEquivalent: "n")
    item.keyEquivalentModifierMask = [.command, .shift]
    return [item]
  }
  
  
  private func setupThemesMenu() {
    let themeMenuItems = createThemesMenuItems()
    themeMenu?.items = themeMenuItems
  }
  
  private func createThemesMenuItems() -> [NSMenuItem] {
    let defaultThemeMenuItem = createDefaultThemeMenuItem()
    let editorDefaultThemeMenuItems = createEditorDefaultThemeMenuItems()
    let usersThemeMenuItems = createUsersThemeMenuItems()
    
    return defaultThemeMenuItem + menuSeporator + editorDefaultThemeMenuItems + menuSeporator + usersThemeMenuItems
  }
  
  private func createDefaultThemeMenuItem() -> [NSMenuItem] {
    let defaultThemeItem = NSMenuItem(title: "Default", action: #selector(switchTheme(_:)), keyEquivalent: "")
    defaultThemeItem.target = self
    defaultThemeItem.identifier = themeMenuId
    return [defaultThemeItem]
  }
  
  private func createEditorDefaultThemeMenuItems() -> [NSMenuItem] {
    return createThemeMenuItems(for: ThemeManager.shared.defaultThemes)
  }
  
  private func createUsersThemeMenuItems() -> [NSMenuItem] {
    return createThemeMenuItems(for: ThemeManager.shared.userDefinedThemes)
  }
  
  private func createThemeMenuItems(for themes: [Theme]) -> [NSMenuItem] {
    guard !themes.isEmpty else { return [] }

    let themeMenuItems: [NSMenuItem] = themes.map{ theme in
      let themeItem = NSMenuItem(title: theme.name,
                                 action: #selector(self.switchTheme(_:)), keyEquivalent: "")
      themeItem.target = self
      themeItem.identifier = themeMenuId
      themeItem.representedObject = theme
      return themeItem
    }
    
    return themeMenuItems
  }
  
  private func setupSettingsMenu() {
    guard let settingsMenuItem = self.settingsMenuItem else { return }
    
    settingsMenuItem.target = self
    settingsMenuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: "settingsMenu")
    settingsMenuItem.action = #selector(openSettings(_:))
  }
  
  //MARK: - Menu item actions
  
  @objc private func newDocument(_ sender: Any?) {
    guard let docType = (sender as? NSMenuItem)?.representedObject as? CreatableDocument.Type else { return }
    documentController?.makeDocument(ofType: docType)
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
    settingsController?.openSettingsEditor()
  }

}

extension WorkbenchContentViewController: NSUserInterfaceValidations {
  func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    if let menuItem = item as? NSMenuItem {
      switch menuItem.identifier {
      case themeMenuId:
        setThemeMenuItemState(to: menuItem)
      default:
        break
      }
    }
    return true
  }
  
  private func setThemeMenuItemState(to menuItem: NSMenuItem) {
    menuItem.state = findThemeMenuItemState(menuItem)
  }
  
  private func findThemeMenuItemState(_ menuItem: NSMenuItem) -> NSControl.StateValue {
    if isActiveTheme(menuItem.representedObject) {
      return .on
    }
    return .off
  }
  
  private func isActiveTheme(_ representedObject: Any?) -> Bool {
    let itemTheme = representedObject as? Theme
    let currentTheme = ThemeManager.shared.selectedTheme
    return itemTheme === currentTheme
  }
}
