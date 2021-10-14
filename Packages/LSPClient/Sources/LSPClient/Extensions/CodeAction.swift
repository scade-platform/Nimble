//
//  CodeAction.swift
//  LSPClient
//  
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

import CodeEditor
import LanguageServerProtocol


// MARK: - SourceCodeQuickfix

extension CodeAction {
  
  var quickFix: SourceCodeQuickfix? {
    guard let kind = self.kind, kind == .quickFix,
          let textEdit = self.edit?.changes?.first?.value.first else { return nil }

    let title = self.title.prefix(1).capitalized + self.title.dropFirst()
    return LSPQuickfix(title: title, textEdit: LSPTextEdit(textEdit: textEdit))
  }
  
}
