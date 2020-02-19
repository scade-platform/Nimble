//
//  LanguageService.swift
//  CodeEditor
//
//  Created by Grigory Markin on 14.01.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation


public protocol LanguageService: class {
  func complete(in: SourceCodeDocument,
                at: String.Index,
                handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) -> Void
}
