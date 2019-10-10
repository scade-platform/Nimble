//
//  HorizontalRootSplitViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 09/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class HorizontalRootSplitViewController: NSSplitViewController {
  
  var workbenchViewController: WorkbenchViewController? {
    return children[0] as? WorkbenchViewController
  }
  
  var consoleViewController: ConsoleController? {
    set {
      guard let value = newValue else {
        if let splitView = consoleSplitViewItem {
          self.removeSplitViewItem(splitView)
          consoleSplitViewItem = nil
          innerConsoleViewController = nil          
        }
        return
      }
      consoleSplitViewItem = NSSplitViewItem(viewController: value)
      self.addSplitViewItem(consoleSplitViewItem!)
      self.innerConsoleViewController = value
    }
    get {
      return innerConsoleViewController
    }
  }
  
  private var innerConsoleViewController: ConsoleController? = nil
  private var consoleSplitViewItem: NSSplitViewItem? = nil
}
