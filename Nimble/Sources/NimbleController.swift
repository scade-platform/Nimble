//
//  NimbleController.swift
//  Nimble
//
//  Created by Danil Kristalev on 02/08/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


// MARK: - Controller

class NimbleController: NSDocumentController {
  
  static func openDocumentHandler(_ doc: NSDocument?, documentWasAlreadyOpen: Bool, error: Error?) {
    ///TODO: process errors
  }
  
  static func openProjectHandler(_ doc: NSDocument?, documentWasAlreadyOpen: Bool, error: Error?) {
    ///TODO: process errors
  }
  
  var currentProjectDocument: ProjectDocument? {
    if currentDocument == nil  {
      self.newDocument(nil)
    }
    
    return currentDocument as? ProjectDocument
  }
  
  
  func makeUntitledDocument(ofType typeClass: CreatableDocument.Type) {
    guard let doc = typeClass.createUntitledDocument() else { return }
    currentWorkbench?.open(doc, show: true)
  }
      
  func open(url: URL, in workbench: Workbench? = nil) {
    if url.typeIdentifierConforms(to: ProjectDocument.docType) {
      openProject(withContentsOf: url, in: workbench)

    } else if let path = Path(url: url) {
      open(path: path, in: workbench)
    }
  }
    
  func open(path: Path, in workbench: Workbench? = nil) {
    let workbench = workbench ?? currentWorkbench
    if path.isDirectory {
      guard let folder = Folder(path: path) else { return }
      workbench?.project?.add(folder)
    } else if path.isFile {
      openDocument(withContentsOf: path.url, in: workbench, display: true)
    }
  }
    
  func openDocument(withContentsOf url: URL, in workbench: Workbench? = nil, display displayDocument: Bool) {
    self.openDocument(withContentsOf: url,
                      in: workbench,
                      display: displayDocument,
                      completionHandler: NimbleController.openDocumentHandler)
  }

  override func openDocument(withContentsOf url: URL, display displayDocument: Bool,
                             completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {

    self.openDocument(openDocument(withContentsOf: url, in: currentWorkbench,
                                   display: displayDocument, completionHandler: completionHandler))
  }

  func openDocument(withContentsOf url: URL,
                    in workbench: Workbench?,
                    display displayDocument: Bool,
                    completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {

    guard let doc = DocumentManager.shared.open(url: url) else {
      return completionHandler(nil, false, nil)
    }

    openDocument(doc, in: workbench, display: displayDocument)
    completionHandler(doc, false, nil)
  }


  func beginOpenProjectPanel(completionHandler: (URL) -> ()) {
    let openPanel = NSOpenPanel();
    guard let url = openPanel.selectFile(ofTypes: [ProjectDocument.docType]) else { return }
    completionHandler(url)
  }
  
  func openProject(withContentsOf url: URL,
                   in workbench: Workbench? = nil) {
    self.openProject(withContentsOf: url, in: workbench, completionHandler: NimbleController.openProjectHandler)
  }
  
  func openProject(withContentsOf url: URL,
                   in workbench: Workbench? = nil,
                   completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {

    let workbenchDocument = (workbench as? NimbleWorkbench)?.document
    let projectDocument = workbenchDocument as? ProjectDocument ?? currentProjectDocument

    if let doc = projectDocument, doc.project.isEmpty {
      do {
        try doc.reload(from: url)
        completionHandler(doc, false, nil)
      } catch {
        completionHandler(nil, false, error)
      }
    } else {
      super.openDocument(withContentsOf: url, display: true, completionHandler: completionHandler)
    }
  }
    
  func updateOpenRecentMenu(_ menu: NSMenu) {
    var urls: [URL] = recentDocumentURLs
    var action: Selector? = #selector(openRecentDocument(_:))
    
    if let menuId = menu.identifier?.rawValue, menuId == AppDelegate.openRecentProjectMenuId {
      urls = recentDocumentURLs.filter {
        $0.typeIdentifierConforms(to: ProjectDocument.docType)
      }
      action = #selector(openRecentProject(_:))
    }
    
    var items: [NSMenuItem] = urls.map {
      let item = NSMenuItem(title: $0.lastPathComponent, action: action, keyEquivalent: "")
      
      let icon = NSWorkspace.shared.icon(forFile: $0.path)
      icon.size = NSSize(width: 16, height: 16)
      
      item.image = icon
      item.representedObject = $0
      
      return item
    }
    
    items.append(NSMenuItem.separator())
    menu.items.replaceSubrange(0..<menu.items.count - 1, with: items)
  }
  
  @objc func openRecentDocument(_ sender: Any?) {
    guard let url = (sender as? NSMenuItem)?.representedObject as? URL else { return }
    openDocument(withContentsOf: url, display: true)
  }
  
  @objc func openRecentProject(_ sender: Any?) {
    guard let url = (sender as? NSMenuItem)?.representedObject as? URL else { return }
    openProject(withContentsOf: url)
  }
}

// MARK: - DocumentController

extension NimbleController: DocumentController {
  var currentWorkbench: Workbench? {
    return currentProjectDocument?.workbench
  }

  func openDocument(_ doc: Document, display displayDocument: Bool) {
    self.openDocument(doc, in: currentWorkbench, display: displayDocument)
  }

  func openDocument(_ doc: Document, in workbench: Workbench?, display displayDocument: Bool) {
    noteNewRecentDocument(doc)

    if let workbench = currentWorkbench, displayDocument {
      workbench.open(doc, show: true)
    }
  }
}


// MARK: - Actions

extension NimbleController {
  @IBAction func open(_ sender: Any?) {
    let openPanel = NSOpenPanel();
    openPanel.selectAny()
      .compactMap{Path(url: $0)}
      .forEach{open(path: $0)}
  }
  
  @IBAction func openProject(_ sender: Any?) {
    beginOpenProjectPanel {
      openProject(withContentsOf: $0)
    }
  }
    
  @IBAction func switchProject(_ sender: Any?) {
    beginOpenProjectPanel {
      do {
        try currentProjectDocument?.reload(from: $0)
      } catch {
        /// TODO: implement
      }
    }
  }
}
