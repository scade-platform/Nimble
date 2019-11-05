//
//  ProjectNavigatorPart.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 14.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

open class ProjectNavigatorPart: WorkbenchPart {
  public var title: String?
  
  public var icon: NSImage? = nil
  
  public var view: NSView {
    return outlineView
  }
  
  private var folders: RootItem?
  private var openedDocuments: OpenedDocumentsSource?
  
  internal var workbench: Workbench? = nil {
    didSet {
      guard let workbench = workbench else {return}
      outlineView.workbench = workbench
      folders = FoldersSource(title: "FOLDERS", cell: "Data cell", workbench: workbench)
      openedDocuments = OpenedDocumentsSource(title: "OPENED DOCUMENTS", cell: "ClosableDataCell")
      outlineDataSource = ProjectOutlineDataSource(workbench, foldersRootItem: folders!, openedDocumentsRootItem: openedDocuments!)
      outlineView.outline?.delegate = outlineDataSource
      outlineView.outline?.dataSource = outlineDataSource
      outlineView.outline?.floatsGroupRows = false
      outlineView.outline?.expandItem(folders)
      
    }
  }
  
  private var outlineView: ProjectOutlineView
  
  private var outlineDataSource: ProjectOutlineDataSource? = nil
  
  public init() {
    title = "Project"
    icon = Bundle(for: type(of: self)).image(forResource: "navigatorPart")
    outlineView = ProjectOutlineView()
  }
  
}


public class ProjectOutlineDataSource: NSObject {
  private let workbench: Workbench
  private let folders: RootItem
  private let openDocuments: RootItem
  
  fileprivate init?(_ workbench: Workbench?, foldersRootItem folders: RootItem, openedDocumentsRootItem openDocuments: RootItem) {
    guard let _workbench = workbench else { return nil }
    self.workbench = _workbench
    self.folders = folders
    self.openDocuments = openDocuments
  }
}


extension ProjectOutlineDataSource: NSOutlineViewDataSource {
  public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item else {
      if index == 0 {
        return openDocuments
      } else {
        return folders
      }
    }
    switch item {
    case let root as OpenedDocumentsSource:
      return root.data[index]
    case let root as FoldersSource:
      return root.data[index]
    case let folder as Folder:
      guard let foldersContent = folder.content else {
        showPermissionAlert(path: folder.path.url)
        return self
      }
      return foldersContent[index]
    default:
      return self
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    switch item {
    case let root as OpenedDocumentsSource:
      return root.data.count > 0
    case let root as FoldersSource:
      return root.data.count > 0
    case let folder as Folder:
      if folder.path.exists{
        guard let foldersContent = folder.content else {
          showPermissionAlert(path: folder.path.url)
          return false
        }
        return foldersContent.count > 0
      }else {
        return false
      }
    default:
      return false
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 2 }
    
    switch item {
    case let root as OpenedDocumentsSource:
      return root.data.count
    case let root as FoldersSource:
      return root.data.count
    case let folder as Folder:
      guard let foldersContent = folder.content else {
        showPermissionAlert(path: folder.path.url)
        return 0
      }
      return !folder.path.isSymlink ? foldersContent.count : 0
    default:
      return 0
    }
  }
  
  func showPermissionAlert(path: URL){
    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText =  "Permission denied:"
      alert.informativeText = path.absoluteString
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .warning
      alert.runModal()
    }
  }
}

extension ProjectOutlineDataSource: NSOutlineViewDelegate {
  public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return item is RootItem
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return !(item is RootItem)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is RootItem)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case let root as RootItem:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = root.title
      return view
    case let folder as Folder:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = folder.name
      
      if outlineView.isItemExpanded(item) {
        view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "folder-open")
      } else {
        view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "folder-close")
      }
      
      return view
    case let file as File:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView else { return nil }
      view.objectValue = item
      view.textField?.stringValue = file.name
      view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "document")
      return view
    case let document as Document:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ClosableDataCell"), owner: self) as? NSTableCellView else { return nil }
      if let closableView = view as? FileTableCellView {
        closableView.closeDocumentCallback = { [unowned self] document in
          self.workbench.close(document: document)
        }
      }
      view.objectValue = document
      view.textField?.stringValue = document.title
      view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "document")
      return view
    default:
      return nil
    }
  }
  
  public func outlineViewSelectionDidChange(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView else { return }
    if let item = outlineView.item(atRow: outlineView.selectedRow) as? File {
      self.workbench.preview(file: item)
    }
    if let item = outlineView.item(atRow: outlineView.selectedRow) as? Document {
      self.workbench.preview(document: item)
    }
  }
  
  public func outlineViewItemDidExpand(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView else { return }
    guard let item = notification.userInfo?["NSObject"] else { return }
    outlineView.reloadItem(item, reloadChildren: false)
  }
  
  public func outlineViewItemDidCollapse(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView else { return }
    guard let item = notification.userInfo?["NSObject"] else { return }
    outlineView.reloadItem(item, reloadChildren: false)
  }
  
  func checkForSave(file: File) -> Bool {
//    if workbench.changedFiles?.contains(file) ?? false{
//      let result = saveDialog(question: "Do you want to save the changes you made to \(file.name)? ", text: "Your changes will be lost if you don't save them")
//      if result.save {
//        workbench.save(file: file)
//      }
//      return result.close
//    }
    return true
  }
}

func saveDialog(question: String, text: String) -> (save: Bool, close: Bool) {
  let alert = NSAlert()
  alert.messageText = question
  alert.informativeText = text
  alert.alertStyle = .warning
  alert.addButton(withTitle: "Save")
  alert.addButton(withTitle: "Cancel")
  alert.addButton(withTitle: "Don't Save")
  let result = alert.runModal()
  return (save: result == .alertFirstButtonReturn, close:  result == .alertThirdButtonReturn || result == .alertFirstButtonReturn)
}

protocol DataSource : class {
  associatedtype DataType
  var data: [DataType] { get }
}

fileprivate class RootItem: NSObject {
  let title: String
  let cell: String
  
  init(title: String, cell: String){
    self.title = title
    self.cell = cell
  }
}

fileprivate class FoldersSource: RootItem {
  let workbench: Workbench
  
  init(title: String, cell: String, workbench: Workbench){
    self.workbench = workbench
    super.init(title: title, cell: cell)
  }
}

extension FoldersSource : DataSource {
  var data: [Folder] {
    return workbench.project?.folders ?? []
  }
}

fileprivate class OpenedDocumentsSource: RootItem {
  var openedDocuments : [Document] = []
}

extension OpenedDocumentsSource : DataSource {
  var data: [Document] {
    return openedDocuments
  }
}

extension ProjectNavigatorPart : ProjectObserver {
  public func project(_ project: Project, didUpdated folders: [Folder]) {
    outlineView.outline?.reloadData()
    DispatchQueue.main.async {
      self.outlineView.outline?.expandItem(self.folders)
    }
  }
  
  public func projectDidChanged(_ newProject: Project) {
    outlineView.outline?.reloadData()
    DispatchQueue.main.async {
      self.outlineView.outline?.expandItem(self.folders)
    }
  }
}

extension ProjectNavigatorPart : WorkbenchObserver {
  public func documentDidOpen(_ document: Document) {
    openedDocuments?.openedDocuments.append(document)
    outlineView.outline?.reloadData()
    DispatchQueue.main.async {
      self.outlineView.outline?.expandItem(self.openedDocuments)
    }
  }
  
  public func documentDidClose(_ document: Document) {
    guard let index = openedDocuments?.openedDocuments.firstIndex(where: {$0 === document}) else {
      return
    }
    openedDocuments?.openedDocuments.remove(at: index)
    outlineView.outline?.reloadData()
    DispatchQueue.main.async {
      self.outlineView.outline?.expandItem(self.openedDocuments)
    }
  }
}

