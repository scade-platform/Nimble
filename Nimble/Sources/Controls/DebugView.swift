//
//  InfoViewController.swift
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
