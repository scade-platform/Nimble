//
//  Completion.swift
//  CodeEditor
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
