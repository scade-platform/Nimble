//
//  ProjectDocument.swift
//  Nimble
//
//  Created by Danil Kristalev on 31/07/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore

class ProjectDocument : NSDocument {
  
  var project: Project? = nil
  
  var workbench: Workbench? {
    return self.windowForSheet?.windowController as? Workbench
  }
  
  private var incorrectPaths : [String]?
  
  override init() {
    super.init()
    project = ProjectManager.shared.create()
  }
  
  init(contentsOf url: URL, ofType typeName: String) throws {
    super.init()
    project = ProjectManager.shared.create(projectFile: url)
    try read(from: url, ofType: typeName)
    self.fileURL = url
    self.fileType = typeName
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
    return ofType == "com.scade.nimble.project"
  }
  
  
  // MARK: - User Interface
  
  override func makeWindowControllers() {
    // Returns the storyboard that contains your document window.
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    if let windowController =
      storyboard.instantiateController(
        withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController {
      addWindowController(windowController)
      showIncorrectPaths()
    }
  }
  
  func switchProject(contentsOf url: URL, ofType typeName: String) throws {
    project = ProjectManager.shared.create(projectFile: url)
    try read(from: url, ofType: typeName)
    showIncorrectPaths()
  }
  
  // MARK: - Reading and Writing
  
  /// - Tag: readExample
  override func read(from data: Data, ofType typeName: String) throws {
    guard let project = project else {
      return
    }
    incorrectPaths = project.read(from: data)
  }
  
  /// - Tag: writeExample
  override func data(ofType typeName: String) throws -> Data {
    guard let project = project else{
      return Data()
    }
    return project.data(document: self) ?? Data()
  }
  
  func showIncorrectPaths(){
    if let paths = incorrectPaths, !paths.isEmpty {
      let alert = NSAlert()
      alert.messageText =  "Project file has incorrect paths:"
      let pathsMessage = paths.reduce("", {$0 + $1 + "\n"})
      alert.informativeText = pathsMessage
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .warning
      alert.runModal()
    }
  }

  
  func add(folders urls: [URL]){
    guard let project = project else {
      return
    }
    project.add(folders: urls)
  }
  
  func add(files urls: [URL]){
    guard let project = project else {
      return
    }
    project.open(files: urls)
  }
  
  @IBAction func saveProjectAs(_ sender: Any? ){
    saveAs(sender)
  }
  
  override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
    self.fileURL = url
    super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
  }
  
  override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
    savePanel.isExtensionHidden = false
    return true
  }
  
}
