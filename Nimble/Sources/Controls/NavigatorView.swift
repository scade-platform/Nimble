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
  weak var command: Command?
  
  lazy var icon: NSImage? = {
    return Bundle.main.loadBottonImage(name: "leftSideBar")
  }()
  
  
  public override func viewDidLoad() {
    self.title = "Navigator Area"

    command = self.registerCommand()
  }
}

extension NavigatorView: NimbleWorkbenchArea {
  var toolbarIcon: NSImage? {
    icon
  }
  
  var changeVisibleCommand: Command? {
    command
  }
  
  public func add(part: WorkbenchPart) {
    if let part = part as? NSViewController {
      self.addChild(part)
    }
    
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
}
