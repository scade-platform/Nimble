//
//  Settings.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 26.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation
import NimbleCore
import CodeEditor

struct CodeEditorSettings: SettingsGroup {
  static let shared: CodeEditorSettings = CodeEditorSettings()
  
  @SettingDefinition("editor.tabSize", defaultValue: 4)
  private(set) var tabSize: Int

  @SettingDefinition("editor.insertSpaces", defaultValue: false)
  private(set) var insertSpaces: Bool
}


struct EditorSettingDiagnostic {
  let settingDiagnostic: SettingDiagnostic
  let content: String
  
  init(_ content: String, diagnostic: SettingDiagnostic ) {
    self.content = content
    self.settingDiagnostic = diagnostic
  }
}

extension EditorSettingDiagnostic: SourceCodeDiagnostic {
  var fixes: [SourceCodeQuickfix] {
    //TODO: Add quik fix
    return []
  }
  
  func range(in: String) -> Range<Int>? {
    guard let range: Range<String.Index> = content.range(of: settingDiagnostic.key) else {
      return nil
    }
    
    return content.range(for: range)
  }
  
  var message: String {
    settingDiagnostic.message
  }
  
  var severity: DiagnosticSeverity {
    settingDiagnostic.severity
  }
  
  
}
