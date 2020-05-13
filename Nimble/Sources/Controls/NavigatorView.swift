//
//  NavigatorViewController.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

public class NavigatorView: NSViewController {
  @IBOutlet var sidebar: WorkbenchSidebar? = nil
}

extension NavigatorView: WorkbenchArea {
  public func add(part: WorkbenchPart) {
    if let part = part as? NSViewController {
      self.addChild(part)
    }
    
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
  
  public var parts: [WorkbenchPart] {
    self.children.compactMap{$0 as? WorkbenchPart}
  }
}
