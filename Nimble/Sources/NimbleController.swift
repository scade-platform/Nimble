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
    ///TODO: implement
  }
  
  var currentWorkbench: Workbench? {
    return currentProjectDocument?.workbench
  }
  
  var currentProjectDocument: ProjectDocument? {
    if let doc = currentDocument as? ProjectDocument {
      return doc
    }
    return (try? makeUntitledDocument(ofType: ProjectDocument.docType)) as? ProjectDocument
  }
   
  func makeUntitledDocument(ofType typeClass: CreatableDocument.Type) {
    guard let doc = typeClass.createUntitledDocument() else { return }
    currentWorkbench?.open(doc, show: true)
  }
  
  override func openDocument(withContentsOf url: URL, display displayDocument: Bool,
                             completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
            
    guard let doc = DocumentManager.shared.open(url: url) else {
      return completionHandler(nil, false, nil)
    }
        
    guard let workbench = currentWorkbench else {
      return completionHandler(nil, false, nil)
    }
    
    workbench.open(doc, show: true)
    noteNewRecentDocument(doc)
        
    completionHandler(doc, false, nil)
  }
  
  
  func beginOpenProjectPanel(completionHandler: (URL) -> ()) {
    let openPanel = NSOpenPanel();
    guard let url = openPanel.selectFile(ofTypes: [ProjectDocument.docType]) else { return }
    completionHandler(url)
  }
      
  func openProject(withContentsOf url: URL, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void)  {
    if let doc = currentProjectDocument, doc.project.isEmpty {
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
    
    if let menuId = menu.identifier?.rawValue, menuId == "openRecentProjects" {
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
    openDocument(withContentsOf: url, display: true,
                 completionHandler: NimbleController.openDocumentHandler)
  }
  
  @objc func openRecentProject(_ sender: Any?) {
    guard let url = (sender as? NSMenuItem)?.representedObject as? URL else { return }
    openProject(withContentsOf: url,
                completionHandler: NimbleController.openDocumentHandler)
  }
  
  
}

// MARK: - Actions

extension NimbleController {
  
  
  @IBAction func open(_ sender: Any?) {
    let openPanel = NSOpenPanel();
    let urls = openPanel.selectAny().compactMap { Path(url: $0) }
    
    urls.filter{ $0.isDirectory }.forEach {
      guard let folder = Folder(path: $0) else { return }
      currentProjectDocument?.project.add(folder)
    }
    
    urls.filter{ $0.isFile }.forEach {
      openDocument(withContentsOf: $0.url, display: true,
                   completionHandler: NimbleController.openDocumentHandler)
    }
  }
  
  @IBAction func openProject(_ sender: Any?) {
    beginOpenProjectPanel {
      openProject(withContentsOf: $0,
                  completionHandler: NimbleController.openDocumentHandler)
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
