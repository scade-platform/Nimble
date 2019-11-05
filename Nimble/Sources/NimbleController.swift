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
    if let type = defaultType, let currentProjectDocument = currentDocument as? ProjectDocument {
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
    guard let currentProjectDocument = self.currentDocument as? ProjectDocument else {
      return
    }
    currentProjectDocument.add(folders: openPanel.urls)
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
    guard let currentProjectDocument = self.currentDocument as? ProjectDocument else {
      return
    }
    currentProjectDocument.open(files: openPanel.urls)
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
}
