//
//  Settings.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 26.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation
import NimbleCore

struct CodeEditorSettings {
  @Setting("editor.tabSize", defaultValue: 4)
  static var tabSize: Int

  @Setting("editor.insertSpaces", defaultValue: false)
  static var insertSpaces: Bool

  static func register() {
    Settings.shared.add(self.$tabSize)
    Settings.shared.add(self.$insertSpaces)
  }
}
