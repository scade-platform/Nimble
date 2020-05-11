//
//  NimbleStatusBar.swift
//  Nimble
//
//  Created by Grigory Markin on 09.05.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit
import NimbleCore

class NimbleStatusBar: NSViewController {
  @IBOutlet weak var statusIcon: NSImageView!
  @IBOutlet weak var statusMessage: NSTextField!
}

class NimbleStatusBarView: NSView {
  override var intrinsicContentSize: NSSize {
    return frame.size
  }
}

extension NimbleStatusBarView: WorkbenchStatusBarItem { }
