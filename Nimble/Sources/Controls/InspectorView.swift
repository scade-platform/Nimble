//
//  InspectorView.swift
//  Nimble
//
//  Created by Danil Kristalev on 24/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class InspectorView: NSViewController {
  @IBOutlet weak var sidebar: WorkbenchSidebar? = nil
}

extension InspectorView: NimbleWorkbenchArea {
  func add(part: WorkbenchPart) {
    if let viewController = part as? NSViewController {
      self.addChild(viewController)
    }
    
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
}