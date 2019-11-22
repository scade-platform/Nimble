//
//  OutlineDataSource.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 14.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


class OutlineRootItem: NSObject {
  let title: String
  let cell: String
  weak var workbench: Workbench?
  
  init(title: String, cell: String, workbench: Workbench){
    self.title = title
    self.cell = cell
    self.workbench = workbench
  }
}

class OpenedDocumentsItem: OutlineRootItem {
  init(_ workbench: Workbench) {
    super.init(title: "OPEN FILES", cell: "ClosableDataCell", workbench: workbench)
  }
  
  var documents: [Document] {
    return workbench?.openedDocuments ?? []
  }
}

class ProjectFoldersItem: OutlineRootItem {
  init(_ workbench: Workbench) {
    super.init(title: "FOLDERS", cell: "DataCell", workbench: workbench)
  }
  var folders: [FolderData] {
    let folders = workbench?.project?.folders ?? []
    return folders.map{FolderData($0)}
  }
}

class FolderData {
  let folder: Folder
  private var subfoldersData: [FolderData] = []
  private var files : [File] = []
  
  var data: [Any] {
    if subfoldersData.isEmpty, files.isEmpty {
      try? update()
    }
    return subfoldersData + files
  }
  
  init(_ folder: Folder){
    self.folder = folder
  }
  
  func update() throws {
    try updateSubolders()
    try updateFiles()
  }
  
  private func updateSubolders() throws {
    let subfolders = try folder.subfolders()
    subfoldersData = subfolders.map{FolderData($0)}
  }
  
  private func updateFiles() throws {
    files = try folder.files()
  }
}



// MARK: - OutlineDataSource

class OutlineDataSource: NSObject {
  private weak var outline: NSOutlineView?
  private weak var workbench: Workbench?
  
  let openedDocuments: OpenedDocumentsItem
  let projectFolders: ProjectFoldersItem
  
  init(_ outline: NSOutlineView, for workbench: Workbench) {
    self.outline = outline
    self.workbench = workbench
    
    self.openedDocuments = OpenedDocumentsItem(workbench)
    self.projectFolders = ProjectFoldersItem(workbench)
    
    super.init()
    
    workbench.observers.add(observer: self)
  }
}

extension OutlineDataSource: WorkbenchObserver {
  func workbenchDidChangeProject(_ workbench: Workbench) {
    outline?.reloadItem(projectFolders)
    outline?.expandItem(projectFolders)
  }
  
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    outline?.reloadItem(openedDocuments, reloadChildren: true)
    outline?.expandItem(openedDocuments)
  }
  
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    outline?.reloadItem(openedDocuments, reloadChildren: true)
    outline?.expandItem(openedDocuments)
  }
}

extension OutlineDataSource: NSOutlineViewDataSource {
  public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item else {
      return index == 0 ? openedDocuments : projectFolders
    }
    
    switch item {
    case let item as OpenedDocumentsItem:
      return item.documents[index]
    
    case let item as ProjectFoldersItem:
      return item.folders[index]
      
    case let folderData as FolderData:
      return folderData.data[index]

    default:
      return self
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
  }
  
  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 2 }
    
    switch item {
    case let item as OpenedDocumentsItem:
      return item.documents.count
    
    case let item as ProjectFoldersItem:
      return item.folders.count
      
    case let item as FolderData:
      guard item.folder.path.exists else { return 0 }
      return item.data.count

    default:
      return 0
    }
  }
}


// MARK: - OutlineDelegate

extension OutlineDataSource: NSOutlineViewDelegate {
  public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return item is OutlineRootItem
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return !(item is OutlineRootItem)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is OutlineRootItem)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case let item as OutlineRootItem:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"),
                                            owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = item.title
      return view

    case let item as File:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"),
                                              owner: self) as? NSTableCellView else { return nil }
        
      view.textField?.stringValue = item.name
      view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "document")
      
      return view
      
    case let item as FolderData:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"),
                                            owner: self) as? NSTableCellView else { return nil }
      
      view.textField?.stringValue = item.folder.name
      
      if outlineView.isItemExpanded(item) {
        view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "folder-open")
      } else {
        view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "folder-close")
      }
      
      return view
          
    case let item as Document:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ClosableDataCell"),
                                            owner: self) as? DocumentTableCellView else { return nil }
      
      view.onCloseDocument = { [weak self] in
        self?.workbench?.close($0)
      }
      
      if item.isDocumentEdited {
        view.textField?.font = NSFont.systemFont(ofSize: (view.textField?.font!.pointSize)!)
      }
      
      view.objectValue = item
      view.textField?.stringValue = item.title
      view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "document")
            
      return view
          
    default:
      return nil
    }
  }
        
  public func outlineViewItemDidExpand(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView,
          let item = notification.userInfo?["NSObject"] else { return }

    outlineView.reloadItem(item, reloadChildren: false)
  }
  
  public func outlineViewItemDidCollapse(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView,
          let item = notification.userInfo?["NSObject"] else { return }
    
    outlineView.reloadItem(item, reloadChildren: false)
  }
  
}

