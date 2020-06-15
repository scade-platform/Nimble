//
//  Completion.swift
//  CodeEditor
//
//  Created by Grigory Markin on 30.01.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

public protocol CompletionItem {
  var label: String { get }
  var detail: String? { get }
  var documentation: Documentation? { get }
  var filterText: String? { get }
  var insertText: String? { get }
  var textEdit: TextEdit? { get }
  var kind: CompletionItemKind { get }
}

public enum CompletionItemKind: Int {
  case unknown = 0,
      // LSP 1+
      text,
      method,
      function,
      constructor,
      field,
      variable,
      `class`,
      interface,
      module,
      property,
      unit,
      value,
      reference,
      `enum`,
      keyword,
      snippet,
      color,
      file,
      // LSP 3+
      folder,
      enumMember,
      constant,
      `struct`,
      event,
      `operator`,
      typeParameter
}
