//
//  NimbleProjectController.swift
//  Nimble
//
//  Created by Danil Kristalev on 29/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class NimbleController : NSDocumentController, ProjectControllerProtocol {
  
  private var currentProjectDocument: ProjectDocument? {
    return currentDocument as? ProjectDocument
  }
  
  private var buildMenuItems: [NSMenuItem: Folder] = [:]
  private var runMenuItems: [NSMenuItem: Folder] = [:]
  
  private var buildSubMenu: NSMenu {
    buildMenuItems.removeAll()
    let result = NSMenu()
    guard let folders = currentProjectDocument?.project.folders else {
      return result
    }
    for folder in folders {
      let menuItem = NSMenuItem(title: folder.name, action: #selector(buildFolder(_:)), keyEquivalent: "")
      buildMenuItems[menuItem] = folder
      result.addItem(menuItem)
    }
    return result
  }
  
  private var runSubMenu: NSMenu {
    runMenuItems.removeAll()
    let result = NSMenu()
    guard let folders = currentProjectDocument?.project.folders else {
      return result
    }
    for folder in folders {
      let menuItem = NSMenuItem(title: folder.name, action: #selector(runFolder(_:)), keyEquivalent: "")
      runMenuItems[menuItem] = folder
      result.addItem(menuItem)
    }
    return result
  }
  
  override init(){
    super.init()
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  
  
  @IBAction func switchProject(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = false
    openPanel.canCreateDirectories = false
    if let type = defaultType, let currentProjectDocument = currentProjectDocument {
      let pressedButton = self.runModalOpenPanel(openPanel, forTypes: [type])
      guard pressedButton == NSApplication.ModalResponse.OK.rawValue else {
        return
      }
      guard !openPanel.urls.isEmpty, let url = openPanel.urls.first else {
        return
      }
      try? currentProjectDocument.change(projectTo: url)
    }
  }
  
  @IBAction func addFolderToProject(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = true
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false
    openPanel.canCreateDirectories = false
    let pressedButton = self.runModalOpenPanel(openPanel, forTypes: nil)
    guard pressedButton == NSApplication.ModalResponse.OK.rawValue else {
      return
    }
    currentProjectDocument?.add(folders: openPanel.urls)
  }
  
  @IBAction func openFiles(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = true
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    openPanel.canCreateDirectories = false
    let pressedButton = self.runModalOpenPanel(openPanel, forTypes: nil)
    guard pressedButton == NSApplication.ModalResponse.OK.rawValue else {
      return
    }
    currentProjectDocument?.open(files: openPanel.urls)
  }
  
  @IBAction func showConsole(_ sender: Any?) {
    guard let doc = currentDocument as? ProjectDocument, let workbench = doc.workbench, var debugArea = workbench.debugArea as? Hideable else {
      return
    }
    let hide: Bool
    if let menuItem = sender as? NSMenuItem {
      hide = menuItem.title != "Show Console"
      if hide {
        menuItem.title = "Show Console"
      } else {
        menuItem.title = "Hide Console"
      }
    } else {
      hide = true
    }
    debugArea.isHidden = hide
  }
  
  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if menuItem.tag == 53 {
      menuItem.title = (((currentDocument as! ProjectDocument).workbench?.debugArea) as? Hideable)?.isHidden ?? true ? "Show Console" : "Hide Console"
    }
    if menuItem.tag == 62 {
      if currentProjectDocument?.projectDelegate?.toolchainPath == nil || buildSubMenu.items.count == 0 {
        return false
      }
      menuItem.submenu = buildSubMenu
      return true
    }
    if menuItem.tag == 61 {
      if currentProjectDocument?.projectDelegate?.toolchainPath == nil || runSubMenu.items.count == 0 {
        return false
      }
      menuItem.submenu = runSubMenu
      return true
    }
    return super.validateMenuItem(menuItem)
  }
  
  @objc func buildFolder(_ sender: Any?) {
    guard let menuItem = sender as? NSMenuItem, let selectedFolder = buildMenuItems[menuItem], let projectDelegate = currentProjectDocument?.projectDelegate else {
      return
    }
    projectDelegate.build(folder: selectedFolder)
  }
  
  @objc func runFolder(_ sender: Any?) {
    guard let menuItem = sender as? NSMenuItem, let selectedFolder = runMenuItems[menuItem], let projectDelegate = currentProjectDocument?.projectDelegate else {
      return
    }
    projectDelegate.runSimulator(folder: selectedFolder)
  }
  
  @IBAction func requestTag(_ sender: Any?) {
    guard let menuItem = sender as? NSMenuItem else {
      return
    }
    let _ = menuItem.tag
  }
}
