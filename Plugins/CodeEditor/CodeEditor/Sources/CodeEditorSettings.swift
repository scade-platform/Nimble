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
  static let shared: CodeEditorSettings = CodeEditorSettings()
  
  @SettingDefinition("editor.tabSize", defaultValue: 4)
  private(set) var tabSize: Int

  @SettingDefinition("editor.insertSpaces", defaultValue: false)
  private(set) var insertSpaces: Bool
}
