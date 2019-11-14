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
  
  private var openFiles: RootItem?
  private var folders: RootItem?
  
  internal var workbench: Workbench? = nil {
    didSet {
      guard let workbench = workbench else {return}
      outlineView.workbench = workbench
      openFiles = OpenFiles(workbench: workbench, title: "OPEN FILES", cell: "ClosableDataCell")
      folders = FoldersSource(workbench: workbench, title: "FOLDERS", cell: "DataCell")
      outlineDataSource = ProjectOutlineDataSource(workbench, filesRootItem: openFiles!, foldersRootItem: folders!)
      outlineView.outline?.delegate = outlineDataSource
      outlineView.outline?.dataSource = outlineDataSource
      outlineView.outline?.floatsGroupRows = false
      outlineView.outline?.expandItem(openFiles)
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
  private let openFiles: RootItem
  private let folders: RootItem
  
  init?(_ workbench: Workbench?, filesRootItem openFiles: RootItem, foldersRootItem folders: RootItem) {
    guard let _workbench = workbench else { return nil }
    self.workbench = _workbench
    self.openFiles = openFiles
    self.folders = folders
  }
}


extension ProjectOutlineDataSource: NSOutlineViewDataSource {
  public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item else {
      if index == 0 {
        return openFiles
      }else{
        return folders
      }
    }
    
    switch item {
    case let root as OpenFiles:
      return root.data[index]
    case let root as FoldersSource:
      return root.data[index]
    case let folderData as FolderData:
      return folderData.data[index]
    default:
      return self
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    switch item {
    case let root as OpenFiles:
      return root.data.count > 0
    case let root as FoldersSource:
      return root.data.count > 0
    case let folderData as FolderData:
      if folderData.folder.path.exists {
        return folderData.data.count > 0
      }else{
        return false
      }
    default:
      return false
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 2 }
    
    switch item {
    case let root as OpenFiles:
      return root.data.count
    case let root as FoldersSource:
      return root.data.count
    case let folderData as FolderData:
      return !folderData.folder.path.isSymlink ? folderData.data.count : 0
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
    case let folderData as FolderData:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = folderData.folder.name
      
      if outlineView.isItemExpanded(item) {
        view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "folder-open")
      } else {
        view.imageView?.image = Bundle(for: type(of: self)).image(forResource: "folder-close")
      }
      return view
    case let file as File:
      let parentItem = outlineView.parent(forItem: item)
      let cellName: String
      if let rootItem = parentItem as? RootItem {
        cellName = rootItem.cell
      } else {
        cellName = "DataCell"
      }
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellName), owner: self) as? NSTableCellView else { return nil }
      if let closableView = view as? FileTableCellView {
        closableView.closeFileCallback = { [unowned self] file in
          if self.checkForSave(file: file as! File) {
            self.workbench.project?.close(file: file.path.url)
          }
        }
        if !(workbench.changedFiles?.contains(file) ?? false) {
          view.textField?.font = NSFont.systemFont(ofSize: (view.textField?.font!.pointSize)!)
        }
        
      }
      view.objectValue = item
      view.textField?.stringValue = file.name
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
    if workbench.changedFiles?.contains(file) ?? false{
      let result = saveDialog(question: "Do you want to save the changes you made to \(file.name)? ", text: "Your changes will be lost if you don't save them")
      if result.save {
        workbench.save(file: file)
      }
      return result.close
    }
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

protocol DataSource {
  associatedtype DataType
  var data: [DataType] {get}
}

class RootItem: NSObject {
  let title: String
  let cell: String
  
  init(title: String, cell: String){
    self.title = title
    self.cell = cell
  }
}

class OpenFiles: RootItem, DataSource {
  let workbench: Workbench
  init(workbench: Workbench, title: String, cell: String) {
    self.workbench = workbench
    super.init(title: title, cell: cell)
  }
  
  var data: [FileSystemElement] {
    return self.workbench.project?.files ?? []
  }
}

fileprivate class FoldersSource: RootItem {
  let workbench: Workbench
  private var folders : [FolderData] = []
  
  init(workbench: Workbench, title: String, cell: String){
    self.workbench = workbench
    super.init(title: title, cell: cell)
  }
  
  func refresh() {
    folders.removeAll()
    for folder in workbench.project?.folders ?? [] {
      folders.append(FolderData(parent: folder))
    }
  }
}

extension FoldersSource : DataSource {
  var data: [FolderData] {
    if folders.isEmpty {
      refresh()
    }
    return folders
  }
}

fileprivate class FolderData {
  let cell: String = "Data cell"
  let folder: Folder
  private var parentSubfolders: [FolderData] = []
  private var parentFiles : [File] = []
  
  init(parent: Folder){
    self.folder = parent
  }
  
  func refresh() {
    refreshSubolders()
    refreshFiles()
  }
  
  private func refreshSubolders() {
    let subfolders = Array(folder.subfolders)
    self.parentSubfolders.removeAll()
    for folder in subfolders {
      parentSubfolders.append(FolderData(parent: folder))
    }
    parentSubfolders.sort(by: { $0.folder.name.lowercased() < $1.folder.name.lowercased() })
  }
  
  private func refreshFiles() {
    parentFiles = Array(folder.files).sorted(by: { $0.name.lowercased() < $1.name.lowercased()})
  }
}

extension FolderData: DataSource {
  var data: [Any] {
    if parentSubfolders.isEmpty , parentFiles.isEmpty {
      refresh()
    }
    return parentSubfolders + parentFiles
  }
}

extension ProjectNavigatorPart : ResourceObserver {
  public func changed(event: ResourceChangeEvent) {
    guard let deltas = event.deltas, !deltas.isEmpty, let _ = outlineView.outline else {
      return
    }
    update(openFiles: deltas.filter{$0.resource is File})
    update(folders: deltas.filter{$0.resource is Folder})
  }
  
  private func update(folders deltas: [ResourceDelta]) {
    guard !deltas.isEmpty, let outline = outlineView.outline else {
      return
    }
    let item = outline.item(atRow: outline.selectedRow) as? FileSystemElement
    let folderChangedDeltas = deltas.filter{$0.kind == .changed}.compactMap{$0.deltas}.flatMap{$0}
    if !folderChangedDeltas.isEmpty {
      if let closedItem = folderChangedDeltas.first(where: {$0.resource.path == item?.path}), closedItem.kind == .closed {
        let parent = outline.parent(forItem: item)
        outline.reloadItem(parent, reloadChildren: true)
      }
      if let _ = folderChangedDeltas.first(where: {$0.kind == .added}) {
        outline.reloadItem(item, reloadChildren: true)
      }
    }
    if deltas.contains(where: {$0.kind == .added}){
      outline.reloadItem(folders, reloadChildren: true)
    }
    if !outline.isItemExpanded(folders) {
      outline.expandItem(folders)
    }
  }
  
  private func update(openFiles deltas: [ResourceDelta]) {
    guard !deltas.isEmpty, let outline = outlineView.outline else {
      return
    }
    if let changedItem = deltas.first(where: {$0.kind == .changed}), let cell = cellView(for: changedItem) {
      cell.textField?.font = NSFontManager.shared.convert(NSFont.systemFont(ofSize: (cell.textField?.font!.pointSize)!), toHaveTrait: .italicFontMask)
    }
    if let savedItem = deltas.first(where: {$0.kind == .saved}), let cell = cellView(for: savedItem) {
      if workbench?.changedFiles?.contains(savedItem.resource as! File) ?? false {
        cell.textField?.font = NSFont.systemFont(ofSize: (cell.textField?.font!.pointSize)!)
      }
    }
    outline.reloadItem(openFiles, reloadChildren: true)
    if !outline.isItemExpanded(openFiles) {
      outline.expandItem(openFiles)
    }
  }
  
  private func cellView(for item: Any?) -> NSTableCellView? {
    guard let outline = outlineView.outline, let item = item as? ResourceDelta else {
      return nil
    }
    let countOpenFiles = outline.numberOfChildren(ofItem: openFiles)
    for childIndex in 0..<countOpenFiles {
      let file =  outline.child(childIndex, ofItem: openFiles) as! File
      if file.path == item.resource.path {
        let row = outline.row(forItem: file)
        guard let rowView = outline.rowView(atRow: row, makeIfNecessary: true) else {
          return nil
        }
        guard let cell = rowView.view(atColumn: 0) as? NSTableCellView else {
          return nil
        }
        return cell
      }
    }
    return nil
  }
}

