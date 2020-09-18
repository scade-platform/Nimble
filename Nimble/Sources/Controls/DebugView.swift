//
//  InfoViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 15/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


class DebugView: NimbleSidebarArea {
  weak var consoleView: ConsoleView? = nil
  weak var diagnosticsView: DiagnosticView? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    self.sidebar?.showTabIcon = false
    self.sidebar?.showTabTitle = true

    let diagnosticsView = DiagnosticView.loadFromNib()
    diagnosticsView.title = "PROBLEMS"
    self.diagnosticsView = diagnosticsView
    self.add(part: diagnosticsView)

    let consoleView = ConsoleView.loadFromNib()
    consoleView.title = "OUTPUT"
    self.consoleView = consoleView
    self.add(part: consoleView)

    self.sidebar?.selectView(at: 0)
    self.sidebar?.stackView?.edgeInsets = NSEdgeInsets(top: 2.0, left: 10.0, bottom: 2.0, right: 0.0)
  }
}


extension DebugView {
//  public func add(part: WorkbenchPart) {
//    if let viewController = part as? NSViewController {
//      self.addChild(viewController)
//    }
//
//    ///TODO: improve it, every area should be able to host many views
//    self.view.subviews.removeAll()
//    self.view.addSubview(part.view)
//
//    part.view.translatesAutoresizingMaskIntoConstraints = false
//    part.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//    part.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//    part.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//    part.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
//    part.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//  }
//
//  public var parts: [WorkbenchPart] {
//    self.children.compactMap{$0 as? WorkbenchPart}
//  }
}
