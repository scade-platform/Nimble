//
//  Settings.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 26.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation
import NimbleCore

struct CodeEditorSettings: SettingsGroup {
  static var shared: CodeEditorSettings = CodeEditorSettings()
  
  @SettingDefinition("editor.tabSize", defaultValue: 4)
  var tabSize: Int

  @SettingDefinition("editor.insertSpaces", defaultValue: false)
  var insertSpaces: Bool
}
