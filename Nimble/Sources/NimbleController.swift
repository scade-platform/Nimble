//
//  NimbleController.swift
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

import Cocoa
import NimbleCore


// MARK: - Controller

class NimbleController: NSDocumentController {
  
  @MainMenuItem("File/Open Recent")
  private var openRecentDocumentMenuItem: NSMenuItem?
  
  @MainMenuItem("Project/Open Recent")
  private var openRecentProjectMenuItem: NSMenuItem?
  
  private var openRecentDocumentMenu: NSMenu? {
    openRecentDocumentMenuItem?.submenu
  }
  
  private var openRecentProjectMenu: NSMenu? {
    openRecentProjectMenuItem?.submenu
  }
  
  private var openRecentDocumentMenuDelegate: OpenRecentMenuDelegate?
  private var openRecentProjectMenuDelegate: OpenRecentMenuDelegate?
  
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
      noteNewRecentDocumentURL(folder.url)
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

    self.openDocument(withContentsOf: url,
                      in: currentWorkbench,
                      display: displayDocument,
                      completionHandler: completionHandler)
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
  
  func setupOpenRecentMenu() {
    self.openRecentDocumentMenuDelegate = OpenRecentDocumentMenuDelegate(self)
    self.openRecentProjectMenuDelegate = OpenRecentProjectMenuDelegate(self)
    
    self.openRecentDocumentMenu?.delegate = openRecentDocumentMenuDelegate
    self.openRecentProjectMenu?.delegate = openRecentProjectMenuDelegate
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

    if let workbench = workbench ?? currentWorkbench, displayDocument {
      workbench.open(doc, show: true)
    }
  }
  
  func makeDocument(url: URL? = nil, ofType typeClass: CreatableDocument.Type) {
    guard let doc = typeClass.createDocument(url: url) else { return }
    currentWorkbench?.open(doc, show: true)
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

// MARK: - Open Recent menu

//Abstract class for Open Recent menu delegate.
//There are two different open recent menus: for documents and for projects.
//This class contains basic implementation of menu dalegate and utils methods.
fileprivate class OpenRecentMenuDelegate: NSObject, NSMenuDelegate  {
  weak var nimbleController: NimbleController?
  
  var separator: [NSMenuItem] {
    [.separator()]
  }
  
  init(_ controller: NimbleController) {
    self.nimbleController = controller
  }
  
  func menuNeedsUpdate(_ menu: NSMenu) {
    let recentDocumentURLs: [URL] = nimbleController?.recentDocumentURLs ?? []
    let urls = filterURLs(from: recentDocumentURLs)
    let menuItems = prepareMenuItems(for: urls)
    menu.items.replaceSubrange(0..<menu.items.count - 1, with: menuItems)
  }
  
  func filterURLs(from urls: [URL]) -> [URL] {
    fatalError("Subclasses need to implement the `filterURLs(from:)` method.")
  }
  
  func prepareMenuItems(for urls: [URL]) -> [NSMenuItem] {
    fatalError("Subclasses need to implement the `prepareMenuItems(from:)` method.")
  }
  
  @objc func openRecent(_ sender: Any?) {
    fatalError("Subclasses need to implement the `openRecent(_:)` method.")
  }
  
  func createMenuItem(for url: URL) -> NSMenuItem {
    let item = NSMenuItem(title: url.lastPathComponent, action: #selector(openRecent(_:)), keyEquivalent: "")
    
    let icon = NSWorkspace.shared.icon(forFile: url.path)
    icon.size = NSSize(width: 16, height: 16)
    
    item.image = icon
    item.representedObject = url
    item.target = self
    
    return item
  }
}

fileprivate class OpenRecentDocumentMenuDelegate: OpenRecentMenuDelegate {
  override func filterURLs(from urls: [URL]) -> [URL] {
    urls.filter { !$0.typeIdentifierConforms(to: ProjectDocument.docType) }
  }
  
  override func prepareMenuItems(for urls: [URL]) -> [NSMenuItem] {
    let documentMenuItems = createDocumentMenuItems(from: urls)
    let folderMenuItems = createFolderMenuItems(from: urls)
    return documentMenuItems + separator + folderMenuItems + separator
  }
  
  private func createDocumentMenuItems(from urls: [URL]) -> [NSMenuItem] {
    let documentURLs = urls.filter{!$0.hasDirectoryPath}
    return documentURLs.map{ self.createMenuItem(for: $0) }
  }
  
  private func createFolderMenuItems(from urls: [URL]) -> [NSMenuItem] {
    let folderURLs = urls.filter{$0.hasDirectoryPath}
    return folderURLs.map{ self.createMenuItem(for: $0) }
  }
  
  @objc override func openRecent(_ sender: Any?) {
    guard let url = (sender as? NSMenuItem)?.representedObject as? URL else { return }
    nimbleController?.open(url: url)
  }
}


fileprivate class OpenRecentProjectMenuDelegate: OpenRecentMenuDelegate {

  override func filterURLs(from urls: [URL]) -> [URL] {
    urls.filter { $0.typeIdentifierConforms(to: ProjectDocument.docType) }
  }
  
  override func prepareMenuItems(for urls: [URL]) -> [NSMenuItem] {
    let menuItems = urls.map{ self.createMenuItem(for: $0) }
    return menuItems + separator
  }
  
  @objc override func openRecent(_ sender: Any?) {
    guard let url = (sender as? NSMenuItem)?.representedObject as? URL else { return }
    nimbleController?.openProject(withContentsOf: url)
  }
}
