//
//  NimbleController.swift
//  Nimble
//
//  Created by Danil Kristalev on 02/08/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class NimbleController : NSDocumentController {
  
  public var currentProject: Project? {
    if let doc = currentDocument, let projectDoc = doc as? ProjectDocument {
      return projectDoc.project
    }
    return nil
  }
  
  public override static var shared : NimbleController {
    return NSDocumentController.shared as! NimbleController
  }
  
  //TODO: improve it
  var toolchainPath: String? {
    return ProcessInfo.processInfo.environment["TOOLCHAIN_PATH"]
  }
  
  override init(){
    super.init()
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  
  @IBAction func switchProject(_ sender: Any?) {
    self.beginOpenPanel(completionHandler: self.switchProject(urls:))
  }
  
  private var buildMenuItems: [NSMenuItem: Folder] = [:]
  private var runMenuItems: [NSMenuItem: Folder] = [:]
  
  private var buildSubMenu: NSMenu {
    buildMenuItems.removeAll()
    let result = NSMenu()
    for folder in currentProject?.folders ?? [] {
      let menuItem = NSMenuItem(title: folder.name, action: #selector(buildFolder(_:)), keyEquivalent: "")
      buildMenuItems[menuItem] = folder
      result.addItem(menuItem)
    }
    return result
  }
  
  private var runSubMenu: NSMenu {
    runMenuItems.removeAll()
    let result = NSMenu()
    for folder in currentProject?.folders ?? [] {
      let menuItem = NSMenuItem(title: folder.name, action: #selector(runFolder(_:)), keyEquivalent: "")
      runMenuItems[menuItem] = folder
      result.addItem(menuItem)
    }
    return result
  }

  
  func switchProject(urls: [URL]?) {
    if let url = urls?.first, let doc = self.currentDocument, let projectDoc = doc as? ProjectDocument {
      try! projectDoc.switchProject(contentsOf: url, ofType: self.defaultType!)
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
    addFolderToProject(urls: openPanel.urls)
  }
  
  func addFolderToProject(urls: [URL]?) {
    guard let urls = urls, let doc = self.currentDocument, let projectDoc = doc as? ProjectDocument else {
      return
    }
    projectDoc.add(folders: urls)
  }
  
  @IBAction func addFileToProject(_ sender: Any?) {
    let openPanel = NSOpenPanel()
    openPanel.allowsMultipleSelection = true
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    openPanel.canCreateDirectories = false
    let pressedButton = self.runModalOpenPanel(openPanel, forTypes: nil)
    guard pressedButton == NSApplication.ModalResponse.OK.rawValue else {
      return
    }
    addFilesToProject(urls: openPanel.urls)
  }
  
  func addFilesToProject(urls: [URL]?) {
    guard let urls = urls, let doc = self.currentDocument, let projectDoc = doc as? ProjectDocument else {
      return
    }
    projectDoc.add(files: urls)
  }
  
  override func openDocument(_ sender: Any?) {
    if let project = currentProject {
      if project.files.isEmpty, project.folders.isEmpty, project.name == nil {
        switchProject(sender)
        return
      }
    }
    super.openDocument(sender)
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
      if toolchainPath == nil || buildSubMenu.items.count == 0 {
        return false
      }
      menuItem.submenu = buildSubMenu
      return true
    }
    if menuItem.tag == 61 {
      if toolchainPath == nil || runSubMenu.items.count == 0 {
        return false
      }
      menuItem.submenu = runSubMenu
      return true
    }
    return super.validateMenuItem(menuItem)
  }
  
  @objc func buildFolder(_ sender: Any?) {
    guard let menuItem = sender as? NSMenuItem, let selectedFolder = buildMenuItems[menuItem], let project = currentProject else {
      return
    }
    project.build(folder: selectedFolder)
  }
  
  @objc func runFolder(_ sender: Any?) {
    guard let menuItem = sender as? NSMenuItem, let selectedFolder = runMenuItems[menuItem], let project = currentProject else {
      return
    }
    project.runSimulator(folder: selectedFolder)
  }
  
  @IBAction func requestTag(_ sender: Any?) {
    guard let menuItem = sender as? NSMenuItem else {
      return
    }
    let _ = menuItem.tag
  }
  
  
}
