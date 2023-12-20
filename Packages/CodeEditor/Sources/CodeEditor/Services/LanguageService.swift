//
//  LanguageService.swift
//  CodeEditor
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

import AppKit


public enum LanguageServiceFeature {
  case completion, format, tokenize
}

public protocol LanguageService: AnyObject {
  var supportedFeatures: [LanguageServiceFeature] { get }

  func complete(in: SourceCodeDocument,
                at: String.Index,
                handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) -> Void

  func format(doc: SourceCodeDocument) -> Void

  func tokenize(doc: SourceCodeDocument, range: Range<Int>) -> [SyntaxNode]
}


public struct LanguageServiceRef {
  public private(set) weak var value: LanguageService?
  public init(value: LanguageService) { self.value = value }
}

public extension LanguageService {
  func complete(in: SourceCodeDocument,
                at: String.Index,
                handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) -> Void {}

  func format(doc: SourceCodeDocument) -> Void { }

  func tokenize(doc: SourceCodeDocument, range: Range<Int>) -> [SyntaxNode] { return [] }
}

