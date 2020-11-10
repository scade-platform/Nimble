//
//  SourceCode.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 18.06.19.
//

import NimbleCore

public protocol SourceCodeDocument: Document {
  var text: String { get }
  
  var languageId: String { get }
  
  var languageServices: [LanguageService] { get set }

  func replaceText(with newText: String)
}


public protocol SourceCodeDocumentObserver: DocumentObserver {
  func textDidChange(document: SourceCodeDocument, range: Range<Int>, text: String)
}

public extension SourceCodeDocumentObserver {
  func textDidChange(document: SourceCodeDocument, range: Range<Int>, text: String) {}
}


public protocol SourceCodeDiagnostic: Diagnostic {
  var fixes: [SourceCodeQuickfix] { get }
  func range(`in`: String) -> Range<Int>?
}

public protocol SourceCodeQuickfix {
  var title: String { get }
  var textEdit: TextEdit { get }
}
