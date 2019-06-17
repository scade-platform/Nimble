//
//  Document.swift
//  NimbleCore
//
//  Created by Grigory Markin on 11.06.19.
//

import AppKit


public protocol Document where Self: NSDocument {
  var contentViewController: NSViewController? { get }
}

public extension Document {
  init(_ file: File) throws {
    try self.init(contentsOf: file.path.url, ofType: file.uti)
  }
}


public class DocumentManager {
  private let openedDocumentsCapacity: Int = 10
  
  private var documentClasses: [String: AnyClass] = [:]
  
  private var openedDocuments: [File: Document] = [:]
  private var openedDocumentsQueue: [Document] = []
  
  public static let shared: DocumentManager = DocumentManager()
  
  public func registerDocumentClass<T: Document>(ofType typeName: String, _ docClass: T.Type) {
    documentClasses[typeName] = docClass
  }
  
  public func open(file: File) throws -> Document? {
    if let doc = openedDocuments[file] {
      return doc
    }
    
    if openedDocumentsQueue.count == openedDocumentsCapacity {
      openedDocumentsQueue.removeFirst()
    }
    
    guard let docClass = documentClasses[file.uti] else { return nil }
    
    let doc = try (docClass as! Document.Type).init(file)
    
    openedDocuments[file] = doc
    openedDocumentsQueue.append(doc)
    
    return doc
  }
}


public extension File {
  var uti: String {
    return "public.text"
  }
  
  func open() throws -> Document? {
    return try DocumentManager.shared.open(file: self)
  }
}
