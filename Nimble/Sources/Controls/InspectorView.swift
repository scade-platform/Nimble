//
//  InspectorView.swift
//  Nimble
//
//  Created by Danil Kristalev on 24/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

///TODO: use sidebar panel for the area
class InspectorView: NSViewController {
  @IBOutlet weak var sidebar: WorkbenchSidebar? = nil
}

extension InspectorView: WorkbenchArea {
  func add(part: WorkbenchPart) {
    if let viewController = part as? NSViewController {
      self.addChild(viewController)
    }
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
  
  public var parts: [WorkbenchPart] {
    self.children.compactMap{$0 as? WorkbenchPart}
  }

  public func show(part: WorkbenchPart) {

  }
}
