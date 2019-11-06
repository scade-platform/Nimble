//
//  NimbleProjectDocument.swift
//  Nimble
//
//  Created by Danil Kristalev on 29/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class ProjectDocument: NSDocument, ProjectDocumentProtocol {
  
  private(set) var project: Project = Project()
  
  private var nimbleWorkbench: NimbleWorkbench? {
     return self.windowForSheet?.windowController as? NimbleWorkbench
  }
  
  var workbench: Workbench? {
    return nimbleWorkbench
  }
  
  var notificationCenter: ProjectNotificationCenter {
    return self
  }
  
  override var fileURL: URL? {
    didSet {
      project.location = fileURL?.deletingLastPathComponent()
    }
  }
  
  private var observations = [ObjectIdentifier : Observation]()
  
  override init() {
    super.init()
    project.observer = self
  }
  
  convenience init(contentsOf url: URL, ofType typeName: String) throws {
    self.init()
    project.observer = self
    self.fileURL = url
    self.fileType = typeName
    try read(from: url, ofType: typeName)
  }
  
  override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
    return true
  }
  
  override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {
    return ofType == "com.scade.nimble.project"
  }
  
  override func makeWindowControllers() {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    if let windowController =
      storyboard.instantiateController(
        withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController {
      addWindowController(windowController)
      if let workbench = windowController as? NimbleWorkbench {
        workbench.launch()
      }
    }
  }
  
  override func read(from data: Data, ofType typeName: String) throws {
    try project.read(from: data, incorrectPathHandler: {incorrectPaths in
      if Thread.isMainThread {
        self.showAlert(incorrectPaths)
      } else {
        DispatchQueue.main.async {
          self.showAlert(incorrectPaths)
        }
      }
    })
  }
  
  override func data(ofType typeName: String) throws -> Data {
    return try project.data()
  }
  
  override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
    self.fileURL = url
    super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
  }
  
  override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
    savePanel.isExtensionHidden = false
    return true
  }
  
  @IBAction func saveProjectAs(_ sender: Any? ){
    saveAs(sender)
  }
  
  @IBAction func saveCurrentDocument(_ sender: Any? ){
    guard let document = nimbleWorkbench?.currentDocument else {
      return
    }
    save(document: document)
  }
  
  @IBAction func saveCurrentDocumentAs(_ sender: Any? ){
    guard let document = nimbleWorkbench?.currentDocument else {
      return
    }
    saveAs(document: document)
  }
  
  @IBAction func closeCurrentDocument(_ sender: Any?) {
    guard let document = nimbleWorkbench?.currentDocument else {
      return
    }
    nimbleWorkbench?.close(document: document)
  }
}

extension ProjectDocument {
  func showAlert(_ incorrectPaths: [String] ) {
    if !incorrectPaths.isEmpty {
      let alert = NSAlert()
      alert.messageText =  "Project file has incorrect paths:"
      let pathsMessage = incorrectPaths.reduce("", {$0 + $1 + "\n"})
      alert.informativeText = pathsMessage
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .warning
      alert.runModal()
    }
  }
  
  func change(projectTo url: URL) throws {
    guard url != fileURL else {
      return
    }
    project = Project()
    fileURL = url
    displayName = url.lastPathComponent
    if let typeName = fileType {
      try read(from: url, ofType: typeName)
    } else if let typeName = ProjectController.shared.defaultType {
      fileType = typeName
      try read(from: url, ofType: typeName)
    }
    projectDidChange()
  }
  
  func add(folders urls: [URL]){
    project.add(folders: urls)
  }
  
  func open(files urls: [URL]) {
    for url in urls where url.file != nil {
      self.workbench?.open(file: url.file!)
    }
  }
  
  func open(all urls: [URL]) {
    add(folders: urls)
    open(files: urls)
  }
  
  func save(document: Document) {
    document.save(nil)
    nimbleWorkbench?.documentDidSave(document)
  }
  
  func saveAs(document: Document) {
    document.file?.close()
    document.saveAs(nil)
    nimbleWorkbench?.documentDidSave(document)
  }
}

private extension ProjectDocument {
  struct Observation {
    weak var observer: ProjectObserver?
  }
  
  func projectDidChange() {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.projectDidChanged(project)
    }
  }
}

extension ProjectDocument : ProjectObserver {
  func project(_ project: Project, didUpdated folders: [Folder]) {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.project(project, didUpdated: folders)
    }
  }
}


extension ProjectDocument : ProjectNotificationCenter {
  func addProjectObserver(_ observer: ProjectObserver) {
    let id = ObjectIdentifier(observer)
    observations[id] = Observation(observer: observer)
  }
  
  func removeProjectObserver(_ observer: ProjectObserver) {
    let id = ObjectIdentifier(observer)
    observations.removeValue(forKey: id)
  }
}
