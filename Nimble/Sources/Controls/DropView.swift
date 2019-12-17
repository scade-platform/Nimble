//
//  DropView.swift
//  Nimble
//
//  Created by Danil Kristalev on 03/09/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class DropView: NSSplitView, NimbleWorkbenchView {
  lazy var acceptedTypes: [String] = {
    Array(DocumentManager.shared.typeIdentifiers.union(["public.folder"]))
  }()
  
  lazy var filteringOptions =
    [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: acceptedTypes]
  
    
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
  }
  
  override func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation {
    let pasteboard = info.draggingPasteboard
    let accept = pasteboard.canReadObject(forClasses: [NSURL.self], options: filteringOptions)
    return accept ? .copy : NSDragOperation()
  }
  
  override func performDragOperation(_ info: NSDraggingInfo) -> Bool {
    let pasteboard = info.draggingPasteboard
    guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL] else { return false }
    urls.forEach{
      open(url: $0)
    }
    
    return false
  }
  
  
  func open(url: URL) {
    if url.typeIdentifierConforms(to: ProjectDocument.docType) {
      guard let nimbleCtrl = (NSDocumentController.shared as? NimbleController) else { return }
      nimbleCtrl.openProject(withContentsOf: url)
    } else if let path = Path(url: url) {
      open(path: path)
    }
  }
    
  func open(path: Path) {
    if path.isDirectory {
      guard let currentDocument = self.window?.windowController?.document as? ProjectDocument else {return}
      guard let folder = Folder(path: path) else { return }
      currentDocument.project.add(folder)
    } else if path.isFile {
      openDocument(withContentsOf: path.url, display: true)
    }
  }
  
  func openDocument(withContentsOf url: URL, display displayDocument: Bool) {
    guard let nimbleCtrl = (NSDocumentController.shared as? NimbleController),
          let currentDocument = self.window?.windowController?.document as? ProjectDocument,
          let doc = DocumentManager.shared.open(url: url)
    else {
      return
    }
    nimbleCtrl.noteNewRecentDocument(doc)
    if let workbench = currentDocument.workbench, displayDocument {
      workbench.open(doc, show: true)
    }
  }
}

