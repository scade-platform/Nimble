//
//  NavigatorViewController.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

public class NavigatorViewController: NSViewController {
  @IBOutlet var sidebar: WorkbenchSidebar? = nil
}

extension NavigatorViewController: WorkbenchArea {
  public func add(part: WorkbenchPart) {
    sidebar?.appendView(part.view, title: part.title ?? "", icon: part.icon)
  }
}
