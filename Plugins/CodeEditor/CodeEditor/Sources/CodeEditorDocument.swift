//
//  SourceCodeDocument.swift
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

    didSet(lang) {
      guard lang != self.language else { return }
      codeEditor.languageDidChange(language: lang)
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
    
  
  public override var fileURL: URL? {
    get { return super.fileURL }
    set {
      super.fileURL = newValue
      self.language = fileURL?.file?.language
    }
  }
  
  public var directory: URL? = nil

  private var _languageServices: [LanguageServiceRef] = []
  
  public func languageService(for feature: LanguageServiceFeature) -> LanguageService? {
    return _languageServices.first{$0.value?.supportedFeatures.contains(feature) ?? false}?.value
  }


//  public override func save(withDelegate delegate: Any?,
//                            didSave didSaveSelector: Selector?,
//                            contextInfo: UnsafeMutableRawPointer?) {
//
//    super.save(withDelegate: delegate, didSave: didSaveSelector, contextInfo: contextInfo)
//    self.language = fileURL?.file?.language
//  }

  public override func presentedItemDidChange() {
    guard let url = self.fileURL, let type = self.fileType  else { return }

    DispatchQueue.main.async { [weak self] in
      try! self?.read(from: url, ofType: type)
      self?.updateChangeCount(.changeCleared)
    }
  }
    
  public override func read(from url: URL, ofType typeName: String) throws {
    self.language = url.file?.language
    try super.read(from: url, ofType: typeName)
  }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    guard let str =  String(bytes: data, encoding: .utf8) else {
      throw NSError.init(domain: "CodeEditor", code: 1, userInfo: ["FileUrl": self.fileURL ?? ""])
    }
    let content = str.replacingOccurrences(of: "\\r\\n|[\\n\\r\\u2028\\u2029]", with: "\n", options: .regularExpression)
    textStorage.replaceCharacters(in: textStorage.range, with: content)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return textStorage.string.data(using: .utf8)!
  }

  public override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
    savePanel.directoryURL = self.directory
    return super.prepareSavePanel(savePanel)
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

  public var languageServices: [LanguageService] {
    return _languageServices.compactMap{$0.value}
  }

  public func add(service: LanguageService) {
    _languageServices.append(LanguageServiceRef(value: service))
  }

  public func remove(service: LanguageService) {
    _languageServices.removeAll{
      guard let val = $0.value else { return true }
      return ObjectIdentifier(val) == ObjectIdentifier(service)
    }
  }

  public func replaceText(with newText: String) {
    codeEditor.textView.insertText(newText, replacementRange: self.textStorage.string.nsRange)
//    self.textStorage.replaceCharacters(in: self.textStorage.string.nsRange ,
//                                       with: newText)
  }
}

extension CodeEditorDocument: CreatableDocument {
  public static let newMenuTitle: String = "File"

  public static var newMenuKeyEquivalent: String? { "n" }

  public static func createDocument(url: URL?) -> Document? {
    guard let doc = try? CodeEditorDocument(type: "public.text") else {
      return nil
    }
    doc.directory = url
    return doc
  }
}
