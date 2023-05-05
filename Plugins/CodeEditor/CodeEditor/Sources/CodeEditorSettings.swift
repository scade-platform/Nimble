//
//  Settings.swift
//  CodeEditor.plugin
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
    switch settingDiagnostic.location {
    case .key(let key):
      guard let range: Range<String.Index> = content.range(of: key) else {
        return nil
      }
      return content.range(for: range)

    case .mark(let line, let column):
      let lineRange = content.lineRange(line: line) as Range<Int>
      return lineRange.lowerBound..<lineRange.lowerBound + column

    default:
      return nil
    }
  }
  
  var message: String {
    settingDiagnostic.message
  }
  
  var severity: DiagnosticSeverity {
    settingDiagnostic.severity
  }
  
  
}
