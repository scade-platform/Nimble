//
//  Document.swift
//  NimbleCore
//
//  Created by Grigory Markin on 11.06.19.
//

import AppKit


public protocol Document where Self: NSDocument {
  var contentViewController: NSViewController? { get }
  
  static func canOpen(_ file: File) -> Bool
  
  static func isDefault(for file: File) -> Bool
}


public extension Document {
  init(_ file: File) throws {
    try self.init(contentsOf: file.path.url, ofType: file.uti)
  }
  
  static func isDefault(for file: File) -> Bool {
    return false
  }
}


public class DocumentManager {
  private let openedDocumentsCapacity: Int = 10
  
  private var documentClasses: [Document.Type] = []
  
  private var openedDocuments: [File: Document] = [:]
  private var openedDocumentsQueue: [Document] = []
  public private(set) var documentUTI: Set<String> = Set()
  
  public static let shared: DocumentManager = DocumentManager()
  
  public func registerDocumentClass<T: Document>(_ docClass: T.Type, ofTypes uti: [String]? = nil) {
    documentClasses.append(docClass)
    guard let arr = uti else {
      return
    }
    registerOpenableUTI(ofTypes: arr)
  }
  
  public func registerOpenableUTI(ofTypes: [String]){
    ofTypes.forEach{documentUTI.insert($0)}
  }
  
  public func selectDocumentClass(for file: File) -> Document.Type? {
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
  
  public func open(file: File) throws -> Document? {
    if let doc = openedDocuments[file] {
      return doc
    }
    
    if openedDocumentsQueue.count == openedDocumentsCapacity {
      openedDocumentsQueue.removeFirst()
    }
    
    guard let docClass = selectDocumentClass(for: file) else {return nil}
    
    guard let doc = try? docClass.init(file) else {
      return nil
    }
    openedDocuments[file] = doc
    openedDocumentsQueue.append(doc)
    return doc
  }
  
  public func close(file: File) {
    openedDocuments.removeValue(forKey: file)
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
  
  func open() throws -> Document? {
    return try DocumentManager.shared.open(file: self)
  }
  
  func close() {
    DocumentManager.shared.close(file: self)
  }
}
