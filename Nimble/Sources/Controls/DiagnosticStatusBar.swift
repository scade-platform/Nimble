//
//  DiagnosticStatusView.swift
//  Nimble
//
//  Created by Grigory Markin on 08.09.20.
//  Copyright © 2020 SCADE. All rights reserved.
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

    let width = errorsCount.frame.size.width + warningsCount.frame.size.width + 65
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
