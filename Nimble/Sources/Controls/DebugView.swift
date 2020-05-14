//
//  InfoViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 15/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


class DebugView: NSViewController {
  lazy var consoleView: ConsoleView = {
    let console = ConsoleView.loadFromNib()
    self.add(part: console)
    return console
  }()
}


extension DebugView: WorkbenchArea {
  public func add(part: WorkbenchPart) {
    if let viewController = part as? NSViewController {
      self.addChild(viewController)
    }
    
    ///TODO: improve it, every area should be able to host many views
    self.view.subviews.removeAll()
    self.view.addSubview(part.view)
    
    part.view.translatesAutoresizingMaskIntoConstraints = false
    part.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    part.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    part.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    part.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    part.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
  }
  
  public var parts: [WorkbenchPart] {
    self.children.compactMap{$0 as? WorkbenchPart}
  }
}
