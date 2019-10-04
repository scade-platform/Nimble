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
  public var title: String
  
  public var icon: NSImage? = nil
  
  public var view: NSView {
    return outlineView
  }
  
  private var openFiles: DataSource?
  private var folders: DataSource?
  
  internal var workbench: Workbench? = nil {
    didSet {
      guard let workbench = workbench else {return}
      outlineView.workbench = workbench
      openFiles = OpenFiles(workbench: workbench, title: "OPEN FILES", cell: "ClosableDataCell")
      folders = Folders(workbench: workbench, title: "FOLDERS", cell: "DataCell")
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
  private let openFiles: DataSource
  private let folders: DataSource
  
  init?(_ workbench: Workbench?, filesRootItem openFiles: DataSource, foldersRootItem folders: DataSource) {
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
    case let root as DataSource:
      return root.data[index]
    case let folder as Folder:
      guard let foldersContent = folder.content else {
        showPermissionAlert(path: folder.path.url)
        return self
      }
      return foldersContent[index]
    case is Project:
      if index == 0 {
        return openFiles
      }else{
        return folders
      }
    default:
      return self
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    switch item {
    case let root as DataSource:
      return root.data.count > 0
    case let folder as Folder:
      guard let foldersContent = folder.content else {
        showPermissionAlert(path: folder.path.url)
        return false
      }
      return foldersContent.count > 0
    case let project as Project:
      return project.folders.count > 0 || project.files.count > 0
    default:
      return false
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 2 }
    
    switch item {
    case let root as DataSource:
      return root.data.count
    case let folder as Folder:
      guard let foldersContent = folder.content else {
        showPermissionAlert(path: folder.path.url)
        return 0
      }
      return !folder.path.isSymlink ? foldersContent.count : 0
    case _ as Project :
      return 2
      
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
  var data: [FileSystemElement] {get}
}

class RootItem: NSObject {
  let workbench: Workbench
  let title: String
  let cell: String
  
  init(workbench: Workbench, title: String, cell: String){
    self.workbench = workbench
    self.title = title
    self.cell = cell
  }
}

class OpenFiles: RootItem, DataSource {
  var data: [FileSystemElement] {
    return self.workbench.project?.files ?? []
  }
}

class Folders: RootItem, DataSource {
  var data: [FileSystemElement] {
    return self.workbench.project?.folders ?? []
  }
}

extension ProjectNavigatorPart : ResourceObserver {
  public func changed(event: ResourceChangeEvent) {
    guard let deltas = event.deltas, !deltas.isEmpty, let outline = outlineView.outline else {
      return
    }
    let item = outline.item(atRow: outline.selectedRow) as? FileSystemElement
    let itemDelta = deltas.filter{$0.resource.path == item?.path }.first
    outline.reloadData()
    outline.expandItem(openFiles)
    outline.expandItem(folders)
    if let delta = itemDelta, delta.kind != .closed, delta.kind != .removed {
      let row = outline.row(forItem: item)
      outline.selectRowIndexes([row], byExtendingSelection: false)
    }
    if let changedItem = deltas.first(where: {$0.kind == .changed}), let cell = cellView(for: changedItem) {
      cell.textField?.font = NSFontManager.shared.convert(NSFont.systemFont(ofSize: (cell.textField?.font!.pointSize)!), toHaveTrait: .italicFontMask)
    }
    if let savedItem = deltas.first(where: {$0.kind == .saved}), let cell = cellView(for: savedItem) {
      if workbench?.changedFiles?.contains(savedItem.resource as! File) ?? false {
        cell.textField?.font = NSFont.systemFont(ofSize: (cell.textField?.font!.pointSize)!)
      }
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

