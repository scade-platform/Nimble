//
//  WorkbenchArea.swift
//  Nimble
//
//  Created by Danil Kristalev on 03.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


extension WorkbenchArea where Self: NSViewController {
  public var isHidden: Bool {
    set {
      guard let parent = self.parent as? NSSplitViewController else { return }
      parent.splitViewItem(for: self)?.isCollapsed = newValue
    }
    get {
      guard let parent = self.parent as? NSSplitViewController else { return true }
      return parent.splitViewItem(for: self)?.isCollapsed ?? true
    }
  }
}


class ChangeAreaVisibility: Command {
  private let area: (Workbench) -> WorkbenchArea?
  private let areaTitle: String

  init(title: String, icon: NSImage?, area: @escaping (Workbench) -> WorkbenchArea?) {
    self.area = area
    self.areaTitle = title

    super.init(name: "Hide or show the \(title)", menuPath: "View", toolbarIcon: icon)
  }

  override func validate(in workbench: Workbench) -> State {
    guard let area = self.area(workbench) else {
      return []
    }

    self.menuItem?.title = "\(area.isHidden ? "Show" : "Hide") \(areaTitle)"

    var state = super.validate(in: workbench)
    if !area.isHidden {
      state.insert(.selected)
    }

    return state
  }

  override func run(in workbench: Workbench) {
    let area = self.area(workbench)
    area?.isHidden = !(area?.isHidden ?? true)
  }
}



