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
  var command: Command?
  
  lazy var icon: NSImage? = {
    let color = NSColor(named: "ButtonIconColor", bundle: Bundle.main) ?? .darkGray
    let leftSideBarIcon = Bundle.main.image(forResource: "leftSideBar")?.imageWithTint(color)
    return leftSideBarIcon
  }()
  
  
  public override func viewDidLoad() {
    self.title = "Navigator Area"

    command = self.createCommand()
    self.registerCommand()
  }
}

extension NavigatorView: NimbleWorkbenchArea {
  var toolbarIcon: NSImage? {
    return icon
  }
  
  var changeVisibleCommand: Command? {
    return command
  }
  
  public func add(part: WorkbenchPart) {
    if let part = part as? NSViewController {
      self.addChild(part)
    }
    
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
}
