//
//  SettingsDocument.swift
//  Nimble
//
//  Created by Grigory Markin on 21.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit
import NimbleCore

class SettingsDocument: NimbleDocument {
  let editor: WorkbenchEditor? = SettingsEditor.loadFromNib()
}

extension SettingsDocument: Document {
  static var typeIdentifiers: [String]  { return [] }
}
