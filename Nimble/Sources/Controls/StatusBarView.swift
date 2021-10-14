//
//  StatusBarView.swift
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

class StatusBarView: NSViewController {
  @IBOutlet weak var leftBarStackView: NSStackView!
  @IBOutlet weak var rightBarStackView: NSStackView!
  @IBOutlet weak var editorBarStackView: NSStackView!

  private let diagnosticBar = DiagnosticStatusBar.loadFromNib()
  private let workbenchBar = NimbleStatusBar.loadFromNib()

  override func viewDidLoad() {
    super.viewDidLoad()

    leftBar.append(diagnosticBar.view as! WorkbenchStatusBarItem)
    leftBar.append(workbenchBar.view as! WorkbenchStatusBarItem)

    statusMessage = ""
  }

  var editorBar: [WorkbenchStatusBarItem] {
    get {
      return editorBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem}
    }
    set {
      editorBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach{
        guard let view = $0 as? NSView else { return }
        editorBarStackView.insertView(view, at: 0, in: .leading)
      }
    }
  }
}

extension StatusBarView : WorkbenchStatusBar {
  var leftBar: [WorkbenchStatusBarItem] {
    get {
      return leftBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem}
    }
    set {
      leftBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach{
        guard let view = $0 as? NSView else { return }
        leftBarStackView.addView(view, in: .trailing)
      }
    }
  }
    
  var rightBar: [WorkbenchStatusBarItem] {
    get {
      return rightBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem}
    }
    set {
      rightBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach{
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
}



