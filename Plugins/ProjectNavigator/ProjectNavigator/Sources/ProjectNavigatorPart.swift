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
      
      outlineView.outline?.expandItem(workbench?.project)
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
      return workbench.project
    }
    
    switch item {
    case let folder as Folder:
      return folder.content[index]
      
    case let project as Project:
      return project.folders[index]
    default:
      return self
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    switch item {
    case let folder as Folder:
      return folder.content.count > 0
      
    case let project as Project:
      return project.folders.count > 0
      
    default:
      return false
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 1 }
    
    switch item {
    case let folder as Folder:
      return folder.content.count
      
    case let project as Project:
      return project.folders.count
      
    default:
      return 0
    }
  }
}

extension ProjectOutlineDataSource: NSOutlineViewDelegate {
  public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return item is Project
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return !(item is Project)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is Project)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case _ as Project:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = "FOLDERS"
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
  
}
