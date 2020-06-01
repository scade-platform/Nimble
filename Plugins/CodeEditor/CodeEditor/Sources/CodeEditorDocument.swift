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

public final class CodeEditorDocument: NimbleDocument {

  lazy var textStorage = {
    return NSTextStorage()
  }()
  
  public var language: Language? {
    willSet(lang) {
      guard lang != self.language else { return }
      guard let grammar = lang?.grammar else {
        self.syntaxParser = nil
        return
      }
      self.syntaxParser = SyntaxParser(textStorage: textStorage, grammar: grammar)
    }
  }
  
  public var languageServices: [LanguageService] = []

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
    
  
  public override var fileURL: URL? {
    get { return super.fileURL }
    set {
      super.fileURL = newValue
      self.language = fileURL?.file?.language
    }
  }
  
//  public override func save(withDelegate delegate: Any?,
//                            didSave didSaveSelector: Selector?,
//                            contextInfo: UnsafeMutableRawPointer?) {
//
//    super.save(withDelegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
//    self.language = fileURL?.file?.language
//  }
    
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
}


extension CodeEditorDocument: Document {
  public static var typeIdentifiers: [String] {
    ["public.text", "public.data", "public.svg-image"]
  }
  
  public static var usupportedTypes: [String] {
    //all these UTIs in the most cases conforms to public.data
    [ "public.archive", "public.executable", "public.audiovisual-​content",
      "com.microsoft.excel.xls", "com.microsoft.word.doc", "com.microsoft.powerpoint.​ppt"]
  }

  public var editor: WorkbenchEditor? { codeEditor }
}


extension CodeEditorDocument: SourceCodeDocument {
  public var text: String {
//    let text = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: textStorage.range))
//    textStorage.snippets().forEach {
//      text.replaceCharacters(in: $0.range, with: String(repeating: "", count: $0.range.length))
//    }
//    return text.string
    return textStorage.string
  }
  
  public var languageId: String {
    if let lang = language {
      return lang.id
    }
    guard let id = fileURL?.file?.language?.id else { return "" }
    return id
  }
}

extension CodeEditorDocument: CreatableDocument {
  public static let newMenuTitle: String = "File"

  public static var newMenuKeyEquivalent: String? { "n" }

  public static func createUntitledDocument() -> Document? {
    return try? CodeEditorDocument(type: "public.text")
  }
}
