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
    
    @IBOutlet weak var leftBarStackView: NSStackView!
    @IBOutlet weak var editorBarStackView: NSStackView!
    @IBOutlet weak var rightBarStackView: NSStackView!
    
    private let diagnosticBar = DiagnosticStatusBar.loadFromNib()
    private let workbenchBar = NimbleStatusBar.loadFromNib()
    private let actionAreaView = ActionAreaBar.loadFromNib()
    private let problemsAreaView = ActionAreaBar.loadFromNib()
    private let outputsAreaView = ActionAreaBar.loadFromNib()
    private let separatorView = SeparatorView()
    
    var collapseCallback: (() -> Void)?
    var openCallback: (() -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.sidebar?.showTabIcon = false
    self.sidebar?.showTabTitle = true
      
      leftBar.append(problemsAreaView.view as! WorkbenchStatusBarItem)
      leftBar.append(outputsAreaView.view as! WorkbenchStatusBarItem)
      rightBar.append(actionAreaView.view as! WorkbenchStatusBarItem)
      rightBar.append(separatorView)
      rightBar.append(diagnosticBar.view as! WorkbenchStatusBarItem)
      editorBar.append(workbenchBar.view as! WorkbenchStatusBarItem)

      statusMessage = ""

    let diagnosticsView = DiagnosticView.loadFromNib()
    self.diagnosticsView = diagnosticsView
    self.add(part: diagnosticsView)

    let consoleView = ConsoleView.loadFromNib()
    self.consoleView = consoleView
    self.add(part: consoleView)
      
    handleActions()

    self.sidebar?.selectView(at: 0)
    problemsAreaView.changeState(state: .on)
    self.sidebar?.stackView?.edgeInsets = NSEdgeInsets(top: 2.0, left: 10.0, bottom: 2.0, right: 0.0)
  }
    
    func handleActions() {
        actionAreaView.setup(image: NSImage(named: "debugAreaBar"))
        actionAreaView.actionCallback = { [weak self] in
            guard let self = self else { return }
            self.collapseCallback?()
        }
        
        problemsAreaView.setup(image: IconsManager.Icons.warning.image)
        problemsAreaView.actionCallback = { [weak self] in
            guard let self = self else { return }
            self.problemsAreaView.changeState(state: .on)
            self.outputsAreaView.changeState(state: .off)
            self.sidebar?.selectView(at: 0)
            self.openCallback?()
        }
        outputsAreaView.setup(image: IconsManager.Icons.file.image)
        outputsAreaView.actionCallback = { [weak self] in
            guard let self = self else { return }
            self.problemsAreaView.changeState(state: .off)
            self.outputsAreaView.changeState(state: .on)
            self.sidebar?.selectView(at: 1)
            self.openCallback?()
        }
    }
}

// MARK: WorkbenchStatusBar && WorkbenchViewController
extension DebugView: WorkbenchStatusBar, WorkbenchViewController {
  var leftBar: [WorkbenchStatusBarItem] {
    get {
      return leftBarStackView.subviews.compactMap { $0 as? WorkbenchStatusBarItem }
    }
    set {
      leftBarStackView.subviews.forEach { $0.removeFromSuperview() }
      newValue.forEach {
        guard let view = $0 as? NSView else { return }
        leftBarStackView.addView(view, in: .trailing)
      }
    }
  }
    
  var rightBar: [WorkbenchStatusBarItem] {
    get {
      return rightBarStackView.subviews.compactMap { $0 as? WorkbenchStatusBarItem }
    }
    set {
      rightBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach {
        guard let view = $0 as? NSView else { return }
        rightBarStackView.insertView(view, at: 0, in: .leading)
      }
    }
  }
    
    var statusMessage: String {
      get { workbenchBar.statusMessage.stringValue  }
      set { workbenchBar.statusMessage.stringValue = newValue }
    }

    func setStatusMessage(_ message: String, duration: Int) {
      self.statusMessage = message
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) { [weak self] in
        if let currentMessage = self?.statusMessage, currentMessage == message {
          self?.statusMessage = ""
        }
      }
    }
    
    var editorBar: [WorkbenchStatusBarItem] {
      get {
        return editorBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem }
      }
      set {
        editorBarStackView.subviews.forEach { $0.removeFromSuperview() }
        newValue.forEach {
          guard let view = $0 as? NSView else { return }
          editorBarStackView.insertView(view, at: 0, in: .leading)
        }
      }
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
