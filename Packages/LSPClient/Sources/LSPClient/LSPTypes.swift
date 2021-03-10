//
//  LSPDiagnostic.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 19.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import CodeEditor
import LanguageServerProtocol

// MARK: - Diagnostic

struct LSPDiagnostic: SourceCodeDiagnostic {
  let wrapped: LanguageServerProtocol.Diagnostic
    
  var severity: NimbleCore.DiagnosticSeverity {
    guard let severity = wrapped.severity else { return .information }
    switch severity {
    case .error:
      return .error
    case .warning:
      return .warning
    case .hint:
      return .hint
    case .information:
      return .information
    }
  }
  
  var message: String {
    return wrapped.message.prefix(1).capitalized + wrapped.message.dropFirst()
  }

  var fixes: [SourceCodeQuickfix] {
    return wrapped.codeActions?.compactMap {$0.quickFix} ?? []
    
//    return wrapped.relatedInformation?.flatMap { relInfo in
//      relInfo.codeActions?.compactMap {$0.quickFix} ?? []
//    } ?? []
  }

  func range(`in` text: String) -> Range<Int>? {
    guard isValid(range: wrapped.range, for: text) else { return nil }
    return text.range(for: text.range(for: wrapped.range))
  }
}


fileprivate extension LSPDiagnostic {
  func isValid(range: Range<Position>, for string: String) -> Bool {
    
    func isValid(position: Position) -> Bool {
      let lineRange: Range<String.Index> = string.lineRange(line: position.line)
      let startLineIndex = lineRange.lowerBound
      let endLineIndex = lineRange.upperBound
      return string.index(startLineIndex, offsetBy: position.utf16index, limitedBy: endLineIndex) != nil
    }
    
    guard isValid(position: range.lowerBound),
          isValid(position: range.upperBound)
    else { return false }
    return true
  }
}

// MARK: - Quickfix

struct LSPQuickfix: SourceCodeQuickfix {
  var title: String
  var textEdit: CodeEditor.TextEdit
}



// MARK: - TextEdit

struct LSPTextEdit: CodeEditor.TextEdit {
  let textEdit: LanguageServerProtocol.TextEdit

  var newText: String { textEdit.newText }

  func range(`in` text: String) -> Range<Int> {
    text.range(for: text.range(for: textEdit.range))
  }
}


// MARK: - Completion

struct LSPCompletionItem: CodeEditor.CompletionItem {
  let item: LanguageServerProtocol.CompletionItem

  var label: String {
    return item.label
  }

  var detail: String? {
    return item.detail
  }

  var documentation: CodeEditor.Documentation? {
    guard let doc = item.documentation else { return nil }
    switch doc {
    case .string(let val):
      return .plaintext(val)
    case .markupContent(let markup):
      switch markup.kind {
      case .markdown:
        return .markdown(markup.value)
      default:
        return .plaintext(markup.value)
      }
    }
  }

  var filterText: String? { item.filterText }

  var insertText: String? { item.insertText }

  var textEdit: CodeEditor.TextEdit? {
    guard let textEdit = item.textEdit else { return nil }
    return LSPTextEdit(textEdit: textEdit)
  }

  var kind: CodeEditor.CompletionItemKind {
    return CodeEditor.CompletionItemKind(rawValue: item.kind.rawValue) ?? .unknown
  }
}


