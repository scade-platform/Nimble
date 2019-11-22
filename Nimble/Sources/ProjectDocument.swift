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
  
  
/*
  // MARK: - Actions
  @IBAction func saveProjectAs(_ sender: Any? ){
    saveAs(sender)
  }
  
  @IBAction func saveFile(_ sender: Any? ){
    guard let workbench = workbench as? NimbleWorkbench else {
      return
    }
    save(file: (workbench.viewController?.editorViewController?.currentFile!)!)
  }
  
  @IBAction func saveFileAs(_ sender: Any? ){
    guard let workbench = workbench as? NimbleWorkbench else {
      return
    }
    saveAs(file: (workbench.viewController?.editorViewController?.currentFile!)!)
  }
  
  func saveAs(file: File){
    let doc = (try! file.open()!) as NSDocument
    let fileURL = doc.fileURL!
    doc.saveAs(nil)
    project.saved(url: fileURL)
    project.close(file: fileURL)
    project.open(files: [doc.fileURL!])
  }
  
  func save(file: File){
    let doc = (try! file.open()!) as NSDocument
    doc.save(nil)
    project.saved(url: doc.fileURL!)
  }
  
  override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
    self.fileURL = url
    super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
  }
  
  override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
    savePanel.isExtensionHidden = false
    return true
  }
  
  @IBAction func closeFile(_ sender: Any?) {
    guard let workbench = workbench as? NimbleWorkbench else {
      return
    }
    workbench.viewController?.editorViewController?.closeCurrentTab()
  }
*/
  
}
