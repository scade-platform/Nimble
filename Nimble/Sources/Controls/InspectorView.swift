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
  var command: Command?
  
  lazy var icon: NSImage? = {
    let color = NSColor(named: "ButtonIconColor", bundle: Bundle.main) ?? .darkGray
    let rightSideBarIcon = Bundle.main.image(forResource: "rightSideBar")?.imageWithTint(color)
    return rightSideBarIcon
  }()
  
  override func viewDidLoad() {
    self.title = "Inspector Area"
    
    command = self.createCommand()
    self.registerCommand()
  }
}

extension InspectorView: NimbleWorkbenchArea {
  var toolbarIcon: NSImage? {
    icon
  }
  
  
  var changeVisibleCommand: Command? {
    command
  }
  
  func add(part: WorkbenchPart) {
    if let viewController = part as? NSViewController {
      self.addChild(viewController)
    }
    
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
}
