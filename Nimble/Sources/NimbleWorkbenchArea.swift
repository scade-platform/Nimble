//
//  WorkbenchArea.swift
//  Nimble
//
//  Created by Danil Kristalev on 03.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

protocol NimbleWorkbenchArea: WorkbenchArea where Self: NSViewController {
  var changeVisibleCommand: Command? { get }
}

extension NimbleWorkbenchArea {
  var changeVisibleCommand: Command? { nil }
}

extension NimbleWorkbenchArea {
  var parentWorkbench: NimbleWorkbench? {
    return self.view.window?.windowController as? NimbleWorkbench
  }
}

extension NimbleWorkbenchArea {
  public var isHidden: Bool {
    set {
      guard let parent = self.parent as? NSSplitViewController else { return }
      parent.splitViewItem(for: self)?.isCollapsed = newValue
      
      if let command = changeVisibleCommand, let workbench = self.parentWorkbench {
        workbench.commandSates[command]?.isSelected = !newValue
        workbench.commandSates[command]?.title = self.commandTitle
      }
    }
    get {
      guard let parent = self.parent as? NSSplitViewController else { return true }
      return parent.splitViewItem(for: self)?.isCollapsed ?? true
    }
  }
}

extension NimbleWorkbenchArea {

  var commandTitle: String {
    let firstWord = isHidden ? "Show" : "Hide"
    return "\(firstWord) \(self.title ?? "")"
  }
}


