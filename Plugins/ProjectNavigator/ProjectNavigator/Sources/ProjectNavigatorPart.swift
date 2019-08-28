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
  
  internal var workbench: Workbench? = nil {
    didSet {
      outlineDataSource = ProjectOutlineDataSource(workbench)
      
      outlineView.outline?.delegate = outlineDataSource
      outlineView.outline?.dataSource = outlineDataSource
      
      outlineView.outline?.floatsGroupRows = false
      outlineView.outline?.expandItem(workbench?.project.folders)
      outlineView.outline?.expandItem(workbench?.project.files)
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
  
  public init?(_ workbench: Workbench?) {
    guard let _workbench = workbench else { return nil }
    self.workbench = _workbench
  }
}


extension ProjectOutlineDataSource: NSOutlineViewDataSource {
  public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item else {
      if index == 0 {
        return workbench.project.files
      }else{
        return workbench.project.folders
      }
    }
    
    switch item {
    case let arr as [FileSystemElement]:
      return arr[index]
    case let folder as Folder:
      return folder.content[index]
    case let project as Project:
      if index == 0 {
        return project.files
      }else{
        return project.folders
      }
    default:
      return self
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    switch item {
    case let arr as [FileSystemElement]:
      return arr.count > 0
    case let folder as Folder:
      return folder.content.count > 0
    case let project as Project:
      return project.folders.count > 0 || project.files.count > 0
    default:
      return false
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 2 }
    
    switch item {
    case let arr as [FileSystemElement]:
      return arr.count
    case let folder as Folder:
      return !folder.path.isSymlink ? folder.content.count : 0
    case _ as Project :
      return 2
      
    default:
      return 0
    }
  }
}

extension ProjectOutlineDataSource: NSOutlineViewDelegate {
  public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return (item is [Folder])  || (item is [File])
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return !(item is [Folder]) && !(item is [File])
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is [Folder]) && !(item is [File])
  }
  
  public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case let folders as [Folder]:
      guard !folders.isEmpty else {
        return nil
      }
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = "FOLDERS"
      return view
    case _ as [File]:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = "OPEN FILES"
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
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: (outlineView.parent(forItem: item) as? [File]) != nil ? "ClosableDataCell" : "DataCell"), owner: self) as? NSTableCellView else { return nil }
      if let closableView = view as? FileTableCellView {
        closableView.closeFileCallback = { [unowned self] file in
          self.workbench.project.close(file: file.path.url)
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
      self.workbench.open(file: item)
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
  
  struct OutlineRootItem{
    let title: String
    let data: [FileSystemElement]
  }
  
}



extension ProjectNavigatorPart : ResourceObserver {
  public func changed(event: ResourceChangeEvent) {
    guard event.project === workbench?.project, let deltas = event.deltas, !deltas.isEmpty else {
      return
    }
    outlineView.outline?.reloadData()
    outlineView.outline?.expandItem(event.project.files)
    outlineView.outline?.expandItem(event.project.folders)
  }
}

extension ProjectNavigatorPart : ProjectObserver {
  public func changed(project: Project) {
    project.subscribe(resourceObserver: self)
    outlineView.outline?.reloadData()
    outlineView.outline?.expandItem(project.files)
    outlineView.outline?.expandItem(project.folders)
  }
}
