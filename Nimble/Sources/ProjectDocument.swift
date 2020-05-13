//
//  ProjectDocument.swift
//  Nimble
//
//  Created by Danil Kristalev on 31/07/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore

class ProjectDocument: NSDocument {
  static let docType = "com.scade.nimble.project"
  
  var project = Project()
    
  var workbench: NimbleWorkbench? {
    windowControllers.first as? NimbleWorkbench
  }
  
  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)
    workbench?.encodeRestorableState(with: coder)
  }
  
  override func restoreState(with coder: NSCoder) {
    super.restoreState(with: coder)
    workbench?.restoreState(with: coder)
  }
  
  // MARK: - User Interface
  
  override func makeWindowControllers() {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    
    guard let windowController = storyboard.instantiateController(
      withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController else { return }
    
    addWindowController(windowController)
  }
  
  // MARK: - Reading and Writing
  
  override func read(from url: URL, ofType typeName: String) throws {
    guard typeName == ProjectDocument.docType else {
      throw NSError(domain: "ProjectDocument", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document type does not match"])
    }
    
    guard let path = Path(url: url) else {
      throw NSError(domain: "ProjectDocument", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot acces \(url)"])
    }
    
    try project.load(from: path)
  }
  
  
  override func write(to url: URL, ofType typeName: String) throws {
    guard let path = Path(url: url) else {
      throw NSError(domain: "ProjectDocument", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot acces \(url)"])
    }
    
    try project.save(to: path)
  }
  
  func reload(from url: URL) throws {
    guard let path = Path(url: url) else {
      throw NSError(domain: "ProjectDocument", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot acces \(url)"])
    }
    
    try project.load(from: path)
    
    self.fileURL = url
    self.windowControllers.forEach{ $0.document = self }
  }
  
  
  // MARK: - Enablers
  
  // This enables auto save.
  override class var autosavesInPlace: Bool {
    return true
  }
  
  // This enables asynchronous-writing.
  override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
    return true
  }
  
  // This enables asynchronous reading.
  override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {
    return ofType == ProjectDocument.docType
  }
  
  // Closing is allowed iff. all opened documents can close
  // The project itself is saved using autosave functionality
  override func canClose(withDelegate delegate: Any, shouldClose shouldCloseSelector: Selector?, contextInfo: UnsafeMutableRawPointer?) {
    var allowClosing = true
    
    let docs = workbench?.documents ?? []
    for doc in docs where doc.isDocumentEdited {
      allowClosing = doc.close() && allowClosing
      if !allowClosing {
        break
      }
    }
    
    guard let Class: AnyClass = object_getClass(delegate),
          let shouldClose = shouldCloseSelector,
          let contextInfo = contextInfo else { return }

    let method = class_getMethodImplementation(Class, shouldClose)

    typealias signature = @convention(c) (AnyObject, Selector, AnyObject, Bool, UnsafeMutableRawPointer) -> Void
    let function = unsafeBitCast(method, to: signature.self)

    function(delegate as AnyObject, shouldClose, self, allowClosing, contextInfo)
  }
}

// MARK: - Actions

extension ProjectDocument {
  
}
