//
//  Document.swift
//  NimbleCore
//
//  Created by Grigory Markin on 11.06.19.
//

import AppKit

// MARK: - Document

public protocol Document where Self: NSDocument {
  var observers: ObserverSet<DocumentObserver> { get set }
  
  var editor: WorkbenchEditor? { get }
      
  static var typeIdentifiers: [String] { get }
  
  static var usupportedTypes: [String] { get }
          
  static func isDefault(for uti: String) -> Bool
    
  static func canOpen(_ uti: String) -> Bool

  static func isDefault(for file: File) -> Bool

  static func canOpen(_ file: File) -> Bool
}



public protocol DocumentController where Self: NSDocumentController {
  var currentWorkbench: Workbench? { get }    
  func openDocument(_ doc: Document, display displayDocument: Bool) -> Void
  func makeDocument(url: URL?, ofType typeClass: CreatableDocument.Type)
}

public extension DocumentController where Self: NSDocumentController {
  func makeDocument(ofType typeClass: CreatableDocument.Type) {
    makeDocument(url: nil, ofType: typeClass)
  }
}



public extension Document {  
  static var usupportedTypes: [String] {
    return []
  }
  
  var path: Path? {
    guard let url = self.fileURL else { return nil }
    return Path(url: url)
  }
  
  var title: String {
    return path?.basename() ?? "untitled"
  }
  
  static func isDefault(for uti: String) -> Bool {
    return false
  }
  
  static func canOpen(_ uti: String) -> Bool {
    //dynamic UTI also can conforms to standard UTI
    //at the least one of public.item or public.contednt
    guard typeIdentifiers.contains(where: { UTTypeConformsTo(uti as CFString , $0 as CFString) }) else {
      return false
    }
    guard !usupportedTypes.contains(where: { UTTypeConformsTo(uti as CFString , $0 as CFString) }) else {
      return false
    }
    return true
  }

  static func isDefault(for file: File) -> Bool {
    return isDefault(for: file.url.uti)
  }

  static func canOpen(_ file: File) -> Bool {
    return canOpen(file.url.uti)
  }

}


public protocol CreatableDocument where Self: Document {
  static var newMenuTitle: String { get }

  static var newMenuKeyEquivalent: String? { get }
  
  static func createDocument(url: URL?) -> Document?
}

public extension CreatableDocument where Self: Document {
  static func createDocument() -> Document? {
    createDocument(url: nil)
  }
}

public extension CreatableDocument {
  static var newMenuKeyEquivalent: String? { nil }
}


// MARK: - Document Observer

public protocol DocumentObserver {
  func documentDidChange(_ document: Document)
  
  func documentDidSave(_ document: Document)
  func documentWillSave(_ document: Document)
  
  func documentFileDidChange(_ document: Document)
  func documentFileUrlDidChange(_ document: Document, oldFileUrl: URL?)
}

public extension DocumentObserver {
  func documentDidChange(_ document: Document) {}
  func documentDidSave(_ document: Document) {}
  func documentWillSave(_ document: Document) {}
  func documentFileDidChange(_ document: Document) {}
  func documentFileUrlDidChange(_ document: Document, oldFileUrl: URL?) {}
}

// MARK: - Document Manager

public class DocumentManager {
  public static let shared: DocumentManager = DocumentManager()
  
  public var defaultDocument: Document.Type? = nil
  
  private var documentClasses: [Document.Type] = []
  private var openedDocuments: [(ref: WeakRef<NSDocument>, type: Document.Type)] = []

  public var typeIdentifiers: Set<String> {
    documentClasses.reduce(into: []) { $0.formUnion($1.typeIdentifiers) }
  }
  
  public var creatableDocuments: [CreatableDocument.Type] {
    documentClasses.compactMap{ $0 as? CreatableDocument.Type }
  }

  public func findDocumentType(by name: String) -> Document.Type? {
    return documentClasses.first { String(describing: $0) == name }
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
    guard let type = selectDocumentClass(for: file) else { return nil }

    return open(file: file, docType: type)
  }

  public func open(path: Path, docType: Document.Type) -> Document? {
    if let doc = searchOpenedDocument(path, docType: docType) {
      return doc
    }
            
    guard let doc = try? docType.init(contentsOf: path.url, ofType: path.url.uti) else {
      return try? defaultDocument?.init(contentsOf: path.url, ofType: path.url.uti)
    }

    openedDocuments.append((WeakRef<NSDocument>(value: doc), docType))
    return doc
  }

  public func open(file: File, docType: Document.Type) -> Document? {
    return open(path: file.path, docType: docType)
  }
  
  public func open(withContents contents: Data, ofType uti: String) -> Document? {
    guard let docType = selectDocumentClass(for: uti) else { return nil }
    
    let doc = docType.init()
    
    do {
      try doc.read(from: contents, ofType: uti)
    } catch {
      print("\(docType) cannot read data")
    }
    
    openedDocuments.append((WeakRef<NSDocument>(value: doc), docType))
    return doc
  }
  
  public func selectDocumentClasses(for uti: String) -> [Document.Type] {
    return documentClasses.filter { $0.canOpen(uti) }
  }

  public func selectDocumentClasses(for file: File) -> [Document.Type] {
    return documentClasses.filter { $0.canOpen(file) }
  }

  private func selectDocumentClass(for file: File) -> Document.Type? {
    let classes = documentClasses.filter{$0.canOpen(file)}
    return classes.first{$0.isDefault(for: file)} ?? classes.first ?? defaultDocument
  }
  
  private func selectDocumentClass(for uti: String) -> Document.Type? {
    let classes = documentClasses.filter{$0.canOpen(uti)}
    return classes.first{$0.isDefault(for: uti)} ?? classes.first ?? defaultDocument
  }
    
  private func searchOpenedDocument(_ docPath: Path, docType: Document.Type) -> Document? {
    openedDocuments.removeAll{ $0.ref.value == nil }

    let docRef = openedDocuments.first {
      if $0.type == docType {
        guard let path = ($0.ref.value as? Document)?.path else { return false}

        return path == docPath
      } 
      return false
    }
    
    return docRef?.ref.value as? Document
  }
}

// MARK: - DocumentSessionState

public class DocumentSessionState: NSObject, NSCoding {
  public let url: URL?
  public let type: String

  enum Keys: String {
    case url = "url"
    case type = "type"
  }

  required public init(coder aDecoder: NSCoder) {
    url = aDecoder.decodeObject(forKey: Keys.url.rawValue) as? URL
    type = aDecoder.decodeObject(forKey: Keys.type.rawValue) as? String ?? ""
  }

  public init(url: URL?, type: String) {
    self.url = url
    self.type = type
  }

  public convenience init(doc: Document) {
    self.init(url: doc.fileURL, type: String(describing: Swift.type(of: doc)))
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(url, forKey: Keys.url.rawValue)
    aCoder.encode(type, forKey: Keys.type.rawValue)
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
