//
//  SourceCodeDocument.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore
import CodeEditor

public final class SourceCodeDocument: NimbleDocument {
  let textStorage = NSTextStorage()
  
  public var language: Language? {
    didSet {
      if let grammar = language?.grammar {
        self.syntaxParser = SyntaxParser(textStorage: textStorage, grammar: grammar)
      } else {
        self.syntaxParser = nil
      }      
    }
  }
    
  public var syntaxParser: SyntaxParser? {
    didSet {
      codeEditor.highlightSyntax()
    }
  }
  
  private lazy var codeEditor: CodeEditorView = {
    let controller = CodeEditorView.loadFromNib()
    controller.document = self
    return controller
  }()
    
  public var languageId: String {
    if let lang = language {
      return lang.id
    }
    guard let id = fileURL?.file?.language?.id else { return "" }
    return id
  }
  
  public lazy var delegates: [TextDocumentDelegate] = {
    return TextDocumentDelegateManager.shared.createDelegates(for: self)
  }()
  
  
  public override func read(from url: URL, ofType typeName: String) throws {
    self.language = url.file?.language
    try super.read(from: url, ofType: typeName)
  }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    guard let str =  String(bytes: data, encoding: .utf8) else {
      throw NSError.init(domain: "CodeEditor", code: 1, userInfo: ["FileUrl": self.fileURL ?? ""])
    }
    let content = str.replacingLineEndings(with: .lf)
    textStorage.replaceCharacters(in: textStorage.range, with: content)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return textStorage.string.data(using: .utf8)!
  }
  
  public override func updateChangeCount(_ change: NSDocument.ChangeType) {
    let lang = fileURL?.file?.language
    if change == .changeCleared, self.language != lang {
      self.language = lang
    }
    super.updateChangeCount(change)
  }
}


extension SourceCodeDocument: Document {
  public static var usupportedTypes: [String] {
    //all this UTI in the most cases conforms to public.data
    return ["public.archive", "public.executable", "public.audiovisual-​content", "com.microsoft.excel.xls", "com.microsoft.word.doc", "com.microsoft.powerpoint.​ppt"]
  }
  
  
  public var editor: WorkbenchEditor? { codeEditor }
  
  public static var typeIdentifiers: [String] { ["public.text", "public.data", "public.svg-image"] }
}

extension SourceCodeDocument: TextDocument {

}

extension SourceCodeDocument: CreatableDocument {
  public static let newMenuTitle: String = "File"
  public static func createUntitledDocument() -> Document? {
    return try? SourceCodeDocument(type: "public.text")
  }
}
