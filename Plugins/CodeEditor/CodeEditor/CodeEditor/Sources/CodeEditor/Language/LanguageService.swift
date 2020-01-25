//
//  LanguageService.swift
//  CodeEditor
//
//  Created by Grigory Markin on 14.01.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation


public protocol LanguageService: class {
  func complete(_ doc: SourceCodeDocument,
                at: String.Index,
                handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) -> Void
}


public protocol CompletionItem {
  var label: String { get }
  var detail: String? { get }
  var documentation: CompletionItemDocumentation? { get }
  var filterText: String? { get }
  var insertText: String? { get }
  var textEdit: CompletionTextEdit? { get }
}

public enum CompletionItemDocumentation {
  case plaintext(String)
  case markdown(String)
}

public protocol CompletionTextEdit {
  var range: Range<Int> { get }
  var newText: String { get }
}
