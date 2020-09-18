//
//  NimbleSidebarArea.swift
//  Nimble
//
//  Created by Grigory Markin on 03.09.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


public class NimbleSidebarArea: NSViewController {
  @IBOutlet var sidebar: WorkbenchSidebar? = nil
}


extension NimbleSidebarArea: WorkbenchArea {
  public var parts: [WorkbenchPart] {
    self.children.compactMap{$0 as? WorkbenchPart}
  }

  public func add(part: WorkbenchPart) {
    if let part = part as? NSViewController {
      self.addChild(part)
    }
    
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }

  public func show(part: WorkbenchPart) {
    guard let child = part as? NSViewController,
          let pos = self.children.index(of: child) else { return }

    sidebar?.selectView(at: pos)
  }
}


