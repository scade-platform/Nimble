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
  
  override init(){
    super.init()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  
  @IBAction func switchProject(_ sender: Any?) {
    self.beginOpenPanel(completionHandler: self.switchProject(urls:))
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
    if let doc = currentDocument, let projectDoc = doc as? ProjectDocument, let project = projectDoc.project {
      if project.files.isEmpty, project.folders.isEmpty, project.name == nil {
        switchProject(sender)
        return
      }
    }
    super.openDocument(sender)
  }
  
  
}
