//
//  CodeAction.swift
//  
//
//  Created by Grigory Markin on 10.03.21.
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
