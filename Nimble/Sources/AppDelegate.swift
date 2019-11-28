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
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Replace the default delegate installed by the NSDocumentController
    // The default one shows all recent documents without filtering etc.
    openRecentDocumentMenu?.delegate = self
    
    PluginManager.shared.loadPlugins()
    
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
