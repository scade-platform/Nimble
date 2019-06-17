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
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    
//    outline?.backgroundColor = .clear
  }
}
