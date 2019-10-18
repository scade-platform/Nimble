//
//  ProjectOutlineView.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 15.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

open class ProjectOutlineView: XibView {
  
  @IBOutlet var outline: NSOutlineView? = nil
  public var workbench: Workbench? = nil
  
  
  open override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  
  @IBAction func doubleClickedItem(_ sender: Any) {
    guard let outlineView = outline,
      let item = outlineView.item(atRow: outlineView.selectedRow) as? File else { return }
    self.workbench?.open(file: item)
  }
  
  open override func menu(for event: NSEvent) -> NSMenu? {
    guard let outline = outline else {
      return super.menu(for: event)
    }
    let point = outline.convert(event.locationInWindow, from: nil)
    let clickedRow = outline.row(at: point)
    if clickedRow == -1 {
      return super.menu(for: event)
    }
    if clickedRow != outline.selectedRow {
      outline.selectRowIndexes([clickedRow], byExtendingSelection: false)
    }
    self.menu = ProjectNavigatorPlugin.menBuilder.build(outline.item(atRow: clickedRow))
    return super.menu(for: event)
  }
  
}
