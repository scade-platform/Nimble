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
  weak var outline: NSOutlineView?
  
  init(title: String, cell: String, workbench: Workbench, outline: NSOutlineView?){
    self.title = title
    self.cell = cell
    self.workbench = workbench
    self.outline = outline
  }
  
  func reload() {
    outline?.reloadItem(self)
    outline?.expandItem(self)
  }
}

class OpenedDocumentsItem: OutlineRootItem {
  init(_ workbench: Workbench, _ outline: NSOutlineView?) {
    super.init(title: "OPEN FILES",
               cell: "ClosableDataCell",
               workbench: workbench,
               outline: outline)
  }
  
  var documents: [Document] {
    return workbench?.documents ?? []
  }
}

class ProjectFoldersItem: OutlineRootItem {
  init(_ workbench: Workbench, _ outline: NSOutlineView?) {
    super.init(title: "FOLDERS",
               cell: "DataCell",
               workbench: workbench,
               outline: outline)
  }
  var folders: [FolderItem] {
    let folders = workbench?.project?.folders ?? []
    return folders.map{FolderItem($0)}
  }
}

class FolderItem {
  let folder: Folder
  
  // Cached content of the 'folder'
  private var files : [File] = []
  private var items: [FolderItem] = []
  
  var data: [Any] {
    if items.isEmpty, files.isEmpty {
      update()
    }
    return items + files
  }
  
  init(_ folder: Folder){
    self.folder = folder
  }
  
  func update() {
    self.files = (try? folder.files()) ?? []
    
    let subfolders = (try? folder.subfolders()) ?? []
    self.items = subfolders.map{FolderItem($0)}
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
    
    self.openedDocuments = OpenedDocumentsItem(workbench, outline)
    self.projectFolders = ProjectFoldersItem(workbench, outline)
    
    super.init()
    
    workbench.observers.add(observer: self)
  }
}

// MARK: - Observers

extension OutlineDataSource: WorkbenchObserver {
  func workbenchWillChangeProject(_ workbench: Workbench) {
    workbench.project?.observers.remove(observer: self)
  }
  
  func workbenchDidChangeProject(_ workbench: Workbench) {
    workbench.project?.observers.add(observer: self)
    projectFolders.reload()
  }
  
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    document.observers.add(observer: self)
    openedDocuments.reload()
  }
  
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    document.observers.remove(observer: self)
    openedDocuments.reload()
  }
}

extension OutlineDataSource: ProjectObserver {
  func projectFoldersDidChange(_: Project) {
    projectFolders.reload()
  }
}

extension OutlineDataSource: DocumentObserver {
  func documentDidChange(_ document: Document) {
    outline?.reloadItem(document)
  }
}


// MARK: - NSOutlineViewDataSource

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
      
    case let item as FolderItem:
      return item.data[index]

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
      
    case let item as FolderItem:
      guard item.folder.path.exists else { return 0 }
      return item.data.count

    default:
      return 0
    }
  }
}


// MARK: - NSOutlineViewDelegate

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
      
    case let item as FolderItem:
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

