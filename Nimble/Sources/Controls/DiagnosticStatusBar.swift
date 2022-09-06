//
//  DiagnosticStatusView.swift
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

class DiagnosticStatusBar: NSViewController, WorkbenchViewController {
  @IBOutlet weak var errorsIcon: NSImageView!
  @IBOutlet weak var errorsCount: NSTextField!

  @IBOutlet weak var warningsIcon: NSImageView!
  @IBOutlet weak var warningsCount: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    errorsIcon.image = IconsManager.Icons.error.image
    warningsIcon.image = IconsManager.Icons.warning.image
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    workbench?.observers.add(observer: self)

    updateCounts()
  }

  func updateCounts() {
    errorsCount.stringValue = "\(workbench?.diagnostics(severity: .error).values.flatMap{$0}.count ?? 0)"
    warningsCount.stringValue = "\(workbench?.diagnostics(severity: .warning).values.flatMap{$0}.count ?? 0)"

    errorsCount.sizeToFit()
    warningsCount.sizeToFit()

    let width = errorsCount.frame.size.width + warningsCount.frame.size.width + 40
    self.view.setFrameSize(NSSize(width: width, height: self.view.frame.size.height))
    self.view.invalidateIntrinsicContentSize()
  }
}


extension DiagnosticStatusBar: WorkbenchObserver {
  func workbenchDidPublishDiagnostic(_ workbench: Workbench,
                                     diagnostic: [Diagnostic],
                                     source: DiagnosticSource) {
    updateCounts()
  }
}


class DiagnosticStatusBarView: NSView, WorkbenchStatusBarItem {
  override var intrinsicContentSize: NSSize {
    return frame.size
  }
}
