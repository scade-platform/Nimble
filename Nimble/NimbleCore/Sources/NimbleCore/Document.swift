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
    guard !file.uti.starts(with: "dy") else {
      return true
    }
    return typeIdentifiers.contains { file.typeIdentifierConforms(to: $0) }
  }
}


public class DocumentManager {
  private var documentClasses: [Document.Type] = []
  
  private var openedDocuments: [File: WeakRef<NSDocument>] = [:]
  
  public var typeIdentifiers: Set<String> { documentClasses.reduce(into: []) { $0.formUnion($1.typeIdentifiers) } }
  
  public static let shared: DocumentManager = DocumentManager()
      
  public func open(file: File) -> Document? {
    if let doc = searchOpenedDocument(file) {
      return doc
    }
      
    guard let docClass = selectDocumentClass(for: file) else { return nil }
    guard let doc = try? docClass.init(contentsOf: file.path.url, ofType: file.uti) else { return nil }
    
    openedDocuments[file] = WeakRef<NSDocument>(value: doc)
    return doc
  }
  
  public func registerDocumentClass<T: Document>(_ docClass: T.Type) {
    documentClasses.append(docClass)
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
  var uti: String {
    if let resourceValues = try? path.url.resourceValues(forKeys: [.typeIdentifierKey]),
      let uti = resourceValues.typeIdentifier {
        return uti
    }
    return ""
  }
  
  var mime: String {
    guard let mime = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else { return "" }
    return mime.takeRetainedValue() as String
  }
  
  func typeIdentifierConforms(to: String) -> Bool {
    return UTTypeConformsTo(uti as CFString , to as CFString)
  }
  
  func open() -> Document? {
    return DocumentManager.shared.open(file: self)
  }
}
