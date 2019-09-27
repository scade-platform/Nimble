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
//    outline?.backgroundColor = .clear
  }
  
  
  @IBAction func doubleClickedItem(_ sender: Any) {
    guard let outlineView = outline,
      let item = outlineView.item(atRow: outlineView.selectedRow) as? File else { return }
    self.workbench?.open(file: item)
  }
}
