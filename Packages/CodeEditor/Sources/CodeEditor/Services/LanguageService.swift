//
//  LanguageService.swift
//  CodeEditor
//
//  Created by Grigory Markin on 14.01.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation


public enum LanguageServiceFeature {
  case completion, format
}

public protocol LanguageService: class {
  var supportedFeatures: [LanguageServiceFeature] { get }

  func complete(in: SourceCodeDocument,
                at: String.Index,
                handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) -> Void

  func format(doc: SourceCodeDocument) -> Void
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
}

