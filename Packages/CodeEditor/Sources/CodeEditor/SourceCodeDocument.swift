//
//  SourceCode.swift
//  CodeEditorCore
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

import NimbleCore

public protocol SourceCodeDocument: Document {
  var text: String { get }
  var languageId: String { get }

  func add(service: LanguageService)
  func remove(service: LanguageService)
  func service(supporting: LanguageServiceFeature) -> LanguageService?

  func replaceText(with newText: String)
}

public struct SourceCodeDocumentRef {
  public private(set) weak var value: SourceCodeDocument?
  public init(value: SourceCodeDocument) { self.value = value }
}

public protocol SourceCodeDocumentObserver: DocumentObserver {
  func textDidChange(document: SourceCodeDocument, range: Range<Int>, text: String)
  func languageDidChange(document: SourceCodeDocument, language: Language?)
}

public extension SourceCodeDocumentObserver {
  func textDidChange(document: SourceCodeDocument, range: Range<Int>, text: String) {}
  func languageDidChange(document: SourceCodeDocument, language: Language?) {}
}


public protocol SourceCodeDiagnostic: Diagnostic {
  var fixes: [SourceCodeQuickfix] { get }
  func range(`in`: String) -> Range<Int>?
}

public protocol SourceCodeQuickfix {
  var title: String { get }
  var textEdit: TextEdit { get }
}
