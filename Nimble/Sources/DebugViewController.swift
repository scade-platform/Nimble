//
//  InfoViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 15/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

public class DebugViewController: NSViewController {
  
}

extension DebugViewController: WorkbenchArea {
  public func add(part: WorkbenchPart) {
    self.view.subviews.removeAll()
    self.view.addSubview(part.view)
    part.view.translatesAutoresizingMaskIntoConstraints = false
    part.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    part.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    part.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    part.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    part.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
  }
  
}

extension DebugViewController : Hideable {
  public var isHidden : Bool {
    set{
      guard let splitViewController = self.parent as? NSSplitViewController else {
        return
      }
      splitViewController.splitViewItem(for: self)?.isCollapsed = newValue
    }
    get{
      guard let splitViewController = self.parent as? NSSplitViewController else {
        return true
      }
      return splitViewController.splitViewItem(for: self)?.isCollapsed ?? true
    }
  }
}