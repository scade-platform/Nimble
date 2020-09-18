//
//  DiagnosticStatusView.swift
//  Nimble
//
//  Created by Grigory Markin on 08.09.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class DiagnosticStatusBar: NSViewController, NimbleWorkbenchViewController {
  @IBOutlet weak var errorsIcon: NSImageView!
  @IBOutlet weak var errorsCount: NSTextField!

  @IBOutlet weak var warningsIcon: NSImageView!
  @IBOutlet weak var warningsCount: NSTextField!

  override func viewDidAppear() {
    super.viewDidAppear()

    errorsCount.stringValue = "\(workbench?.diagnostics(severity: .error).count ?? 0)"
    warningsCount.stringValue = "\(workbench?.diagnostics(severity: .warning).count ?? 0)"
  }
}
