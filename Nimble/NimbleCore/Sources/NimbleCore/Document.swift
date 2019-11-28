//
//  Document.swift
//  NimbleCore
//
//  Created by Grigory Markin on 11.06.19.
//

import AppKit

// MARK: - Document

public protocol Document where Self: NSDocument {
  var observers: ObserverSet<DocumentObserver> { set get }
  
  var contentViewController: NSViewController? { get }
      
  static var typeIdentifiers: [String] { get }
  
  static func isDefault(for file: File) -> Bool
  
  static func canOpen(_ file: File) -> Bool

}


public protocol DocumentView: class {
  @discardableResult
  func focus() -> Bool
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
  
  func activate() {
    guard let docView = contentViewController?.view as? DocumentView else { return }
    docView.focus()
  }
}


public protocol CreatableDocument where Self: Document {
  static var newMenuTitle: String { get }
  static func createUntitledDocument() -> Document?
}


// MARK: - Default document

open class NimbleDocument: NSDocument {
  public var observers = ObserverSet<DocumentObserver> ()
  
  open override func updateChangeCount(_ change: NSDocument.ChangeType) {
    super.updateChangeCount(change)
    observers.notify {
      guard let doc = self as? Document else { return }
      $0.documentDidChange(doc)
    }
  }
}


// MARK: - Document Observer

public protocol DocumentObserver {
  func documentDidChange(_ document: Document)
}

public extension DocumentObserver {
  func documentDidChange(_ document: Document) {}
}

// MARK: - Document Manager

public class DocumentManager {
  public static let shared: DocumentManager = DocumentManager()
    
  private var documentClasses: [Document.Type] = []
  private var openedDocuments: [WeakRef<NSDocument>] = []
  
  public var typeIdentifiers: Set<String> {
    documentClasses.reduce(into: []) { $0.formUnion($1.typeIdentifiers) }
  }
  
  public var creatableDocuments: [CreatableDocument.Type] {
    documentClasses.compactMap{ $0 as? CreatableDocument.Type }
  }
  
  
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
    
    openedDocuments.append(WeakRef<NSDocument>(value: doc))
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
    openedDocuments.removeAll{ $0.value == nil }
    
    let ref = openedDocuments.first{
      guard let path = ($0.value as? Document)?.path else { return false}
      return path == file.path
    }
    
    return ref?.value as? Document
  }
}


// MARK: - Extensions

public extension File {
//  @discardableResult
//  func open(show: Bool = true) -> Document? {
//    var fileDoc: Document? = nil
//    NSDocumentController.shared.openDocument(withContentsOf: path.url, display: show) {doc, _, _ in
//      fileDoc = doc as? Document
//    }
//    return fileDoc
//  }
}
