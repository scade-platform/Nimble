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
  private var parts = [WorkbenchPart]()
}

extension NavigatorViewController: WorkbenchArea {
  public func add(part: WorkbenchPart) {
    parts.append(part)
    sidebar?.appendView(part.view, title: part.title, icon: part.icon)
  }
  
}

extension NavigatorViewController : WorkbenchDelegate {
  public func projectHasChanged(project: Project) {
    parts.forEach{$0.projectHasChanged(project: project)}
  }
}
