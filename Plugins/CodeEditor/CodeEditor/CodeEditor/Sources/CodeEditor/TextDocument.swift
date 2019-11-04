//
//  SourceCode.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 18.06.19.
//

import NimbleCore

public protocol TextDocument: Document {
  var languageId: String { get }
}

