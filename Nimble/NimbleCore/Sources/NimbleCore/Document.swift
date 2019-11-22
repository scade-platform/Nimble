//
//  Document.swift
//  NimbleCore
//
//  Created by Grigory Markin on 11.06.19.
//

import AppKit


public protocol Document where Self: NSDocument {
  var contentViewController: NSViewController? { get }
  
  static var typeIdentifiers: [String] { get }
  
  static func isDefault(for file: File) -> Bool
  
  static func canOpen(_ file: File) -> Bool
}


public extension Document {
  var path: Path? {
    guard let url = self.fileURL else { return nil }
    return Path(url: url)
  }
  
  var title: String {
    return path?.basename() ?? "untitled"
  }
  
  static func isDefault(for file: File) -> Bool {
    return false
  }
  
  static func canOpen(_ file: File) -> Bool {
    guard !file.url.uti.starts(with: "dy") else {
      return true
    }
    return typeIdentifiers.contains { file.url.typeIdentifierConforms(to: $0) }
  }
}


public class DocumentManager {
  public static let shared: DocumentManager = DocumentManager()
  
  
  private var documentClasses: [Document.Type] = []
  
  private var openedDocuments: [File: WeakRef<NSDocument>] = [:]
  
  public var typeIdentifiers: Set<String> { documentClasses.reduce(into: []) { $0.formUnion($1.typeIdentifiers) } }
  
  
  public func registerDocumentClass<T: Document>(_ docClass: T.Type) {
    documentClasses.append(docClass)
  }

  
  public func open(url: URL) -> Document? {
    guard let path = Path(url: url) else { return nil }
    return open(path: path)
  }
  
  public func open(path: Path) -> Document? {
    guard let file = File(path: path) else { return nil }
    return open(file: file)
  }
  
  public func open(file: File) -> Document? {
    if let doc = searchOpenedDocument(file) {
      return doc
    }
      
    guard let docClass = selectDocumentClass(for: file) else { return nil }
    guard let doc = try? docClass.init(contentsOf: file.path.url, ofType: file.url.uti) else { return nil }
    
    openedDocuments[file] = WeakRef<NSDocument>(value: doc)
    return doc
  }
  

  private func selectDocumentClass(for file: File) -> Document.Type? {
    var docClass: Document.Type? = nil
    for dc in documentClasses {
      if dc.canOpen(file) {
        docClass = dc
      }
      if dc.isDefault(for: file) {
        break
      }
    }
    return docClass
  }
    
  private func searchOpenedDocument(_ file: File) -> Document? {
    var doc: Document? = nil
    for (key, ref) in openedDocuments {
      guard let value = ref.value else {
        openedDocuments.removeValue(forKey: key)
        continue
      }
      
      if file == key {
        doc = value as? Document
      }
    }
    return doc
  }
}


public extension File {
  @discardableResult
  func open(show: Bool = true) -> Document? {
    var fileDoc: Document? = nil
    NSDocumentController.shared.openDocument(withContentsOf: path.url, display: show) {doc, _, _ in
      fileDoc = doc as? Document
    }
    return fileDoc
  }
}
