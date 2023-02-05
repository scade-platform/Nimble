//
//  WorkbenchArea.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

  init(title: String, icon: NSImage?, alignment: ToolbarAlignment, area: @escaping (Workbench) -> WorkbenchArea?) {
    self.area = area
    self.areaTitle = title

    super.init(name: "Hide or show the \(title)", menuPath: "View", toolbarIcon: icon, alignment: alignment)
  }

  override func run(in workbench: Workbench) {
    let area = self.area(workbench)
    area?.isHidden = !(area?.isHidden ?? true)
    if let nimbleWorkbench = workbench as? NimbleWorkbench {
      nimbleWorkbench.updateToolBar()
    }
  }
}



