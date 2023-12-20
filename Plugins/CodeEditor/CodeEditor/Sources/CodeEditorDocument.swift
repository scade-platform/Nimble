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
  private var parser: CodeEditorParser? = nil

  private var parserTask: Task<(), Never>? = nil

  private var services: [LanguageServiceRef] = []

  private lazy var codeEditor: CodeEditorView = {
    let controller = CodeEditorView.loadFromNib()
    controller.document = self
    return controller
  }()

  lazy var textStorage = {
    let storage = NSTextStorage()
    storage.delegate = self

    return storage
  }()


  public var directory: URL? = nil

  public var language: Language? {
    didSet {
      guard self.language != oldValue else { return }
      self.languageDidChange()
    }
  }

  public override var fileURL: URL? {
    get { return super.fileURL }
    set {
      super.fileURL = newValue
      self.language = fileURL?.file?.language
    }
  }

  private func createDocumentParser() -> CodeEditorParser? {
    var tokenizers = [CodeEditorParser.Tokenizer]()

    if let grammar = self.language?.grammar {
      let syntaxParser = SyntaxParser(grammar: grammar)

      tokenizers.append({
        return syntaxParser.tokenize(doc: $0, range: $1)
      })
    }


    return !tokenizers.isEmpty ? CodeEditorParser(document: self, tokenizers: tokenizers) : nil
  }

  private func languageDidChange() {
    self.parserTask?.cancel()
    self.parserTask = nil

    if let parser = createDocumentParser() {
      self.parser = parser

      //self.invalidateDocument()

      self.parserTask = Task.detached {
        for await (range, nodes) in await parser.results {
          Swift.print("Update highlighting")
          await self.updateSyntaxHighlighting(in: range, with: nodes)
        }
      }
    }

    self.observers.notify(as: SourceCodeDocumentObserver.self) {
      $0.languageDidChange(document: self, language: self.language)
    }
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

// MARK: - + Document

extension CodeEditorDocument: Document {
  public static var typeIdentifiers: [String] {
    [
      "public.text",
      "public.data",
      "public.svg-image"]
  }
  
  public static var usupportedTypes: [String] {
    //all these UTIs in the most cases conforms to "public.data" but we don't support them
    [
      "public.archive",
      "public.executable",
      "public.audiovisual-​content",
      "com.microsoft.excel.xls",
      "com.microsoft.word.doc",
      "com.microsoft.powerpoint.​ppt"]
  }

  public var editor: WorkbenchEditor? { codeEditor }
}

// MARK: - + SourceCodeDocument

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

  public func service(supporting feature: LanguageServiceFeature) -> LanguageService? {
    return services.first{$0.value?.supportedFeatures.contains(feature) ?? false}?.value
  }

  public func add(service: LanguageService) {
    //TODO: check if parsers need to be restarted

    services.append(LanguageServiceRef(value: service))
  }

  public func remove(service: LanguageService) {
    //TODO: check if parsers need to be restarted

    services.removeAll{
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


// MARK: - CreatableDocument

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


// MARK: - + NSTextStorageDelegate

extension CodeEditorDocument: NSTextStorageDelegate {
  public func textStorage(_ textStorage: NSTextStorage,
                          didProcessEditing editedMask: NSTextStorageEditActions,
                          range editedRange: NSRange,
                          changeInLength delta: Int) {

    guard editedMask.contains(.editedCharacters) else { return }
    //self.updateChangeCount(.changeDone)


    Task.detached {
      await self.parser?.invalidate(range: editedRange.lowerBound..<editedRange.upperBound,
                                    changeInLength: delta)
    }

    // Notify observers
    if !self.observers.isEmpty {
      let text = String(textStorage.string[editedRange] ?? "")
      let range = editedRange.lowerBound..<editedRange.upperBound - delta

      self.observers.notify(as: SourceCodeDocumentObserver.self) {
        $0.textDidChange(document: self, range: range, text: text)
      }
    }
  }
}


// MARK: - Text changes processing

extension CodeEditorDocument {
  private var textRange: Range<Int> {
    textStorage.range.lowerBound..<textStorage.range.upperBound
  }

  private func invalidateDocument() {
    /*
    if let screenFrame = NSScreen.main?.frame,
       let screenRange = textStorage.layoutManagers.first?.firstTextView?.range(for: screenFrame) {

    }
    */
    /*
    Task {
      await self.parser?.invalidate(range: self.textRange ,changeInLength: 0)
    }
     */
  }
}


// MARK: - Syntax highlighting

extension CodeEditorDocument {
  func updateSyntaxHighlighting(in range: Range<Int>, with nodes: [SyntaxNode]) {
    let nsRange = NSRange(range)

    textStorage.layoutManagers.forEach {
      $0.removeTemporaryAttribute(.foregroundColor, forCharacterRange: nsRange)
    }

    let theme = ThemeManager.shared.currentTheme

    nodes.forEach {
      guard let scope = $0.data,
            let setting = theme?.setting(for: scope) else { return }

      let nodeRange = NSRange($0.range)

//      Swift.print("\(nodeRange.lowerBound)..<\(nodeRange.upperBound) -- \(scope.value)")

      if let color = setting.foreground {
        textStorage.layoutManagers.forEach {
          $0.addTemporaryAttribute(.foregroundColor, value: color, forCharacterRange: nodeRange)
        }
      }

      if let fontStyle = setting.fontStyle, !fontStyle.isEmpty,
         let themeFont = theme?.general.font {

        let font = NSFontManager.shared.convert(themeFont, toHaveTrait: fontStyle)
        textStorage.addAttribute(.font, value: font, range: nodeRange)
      }
    }
  }
}
