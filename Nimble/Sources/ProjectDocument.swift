//
//  ProjectDocument.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import AppKit
import NimbleCore

class ProjectDocument: NSDocument {
  static let docType = "com.scade.nimble.project"
  
  var project: Project
  
  override var fileURL: URL?{
    set {
      project.url = newValue
    }
    get {
      project.url
    }
  }
  
  override init() {
    self.project = Project()
    super.init()
    self.project.observers.add(observer: self)
  }
    
  var workbench: NimbleWorkbench? {
    windowControllers.first as? NimbleWorkbench
  }
  
  override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)
    if project.path == nil {
      let foldersURL = project.folders.map{$0.url}
      coder.encode(foldersURL, forKey: "openFolders")
    }
    workbench?.encodeRestorableState(with: coder)
  }
  
  override func restoreState(with coder: NSCoder) {
    super.restoreState(with: coder)
    if project.path == nil {
      if let foldersURL = coder.decodeObject(forKey: "openFolders") as? [URL] {
        foldersURL.forEach{ url in
          guard let folder = Folder(url: url) else { return }
          project.add(folder)
        }
      }
    }

    // Disable as it should be already restored through the system's call to restore the window state
    // workbench?.restoreState(with: coder)
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
  
  override func data(ofType typeName: String) throws -> Data {
    guard typeName == ProjectDocument.docType else {
      throw NSError(domain: "ProjectDocument", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document type does not match"])
    }
    
    return project.data()!
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

// MARK: - ProjectObserver

extension ProjectDocument: ProjectObserver {
  func projectFoldersDidChange(_: Project) {
    updateChangeCount(.changeDone)
  }
}
