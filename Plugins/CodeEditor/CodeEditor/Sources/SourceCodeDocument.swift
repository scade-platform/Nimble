//
//  SourceCodeDocument.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore
import CodeEditorCore

public final class SourceCodeDocument: NSDocument, TextDocument {
  let textStorage = NSTextStorage()
  
  public var language: Language?
  
  private lazy var editorController: CodeEditorController = {
    let controller = CodeEditorController.loadFromNib()
    controller.doc = self
    return controller
  }()
  
  public var contentViewController: NSViewController? { return editorController }
  
  public var languageId: String {
    if let lang = language {
      return lang.id
    }
    guard let id = self.fileURL?.file?.language?.id else { return "" }
    return id
  }
  
  public lazy var delegates: [TextDocumentDelegate] = {
    return TextDocumentDelegateManager.shared.createDelegates(for: self)
  }()
  
  public class func canOpen(_ file: File) -> Bool {
    guard !file.uti.starts(with: "dy") else {
      return true
    }
    return file.typeIdentifierConforms(to: "public.text") || file.typeIdentifierConforms(to: "public.svg-image")
  }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    guard let str =  String(bytes: data, encoding: .utf8) else {
      throw NSError.init(domain: "NimbleCodeEditor", code: 1, userInfo: ["FileUrl": self.fileURL ?? ""])
    }
    let content = str.replacingLineEndings(with: .lf)
    textStorage.replaceCharacters(in: textStorage.range, with: content)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return textStorage.string.data(using: .utf8)!
  }
}
