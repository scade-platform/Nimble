//
//  File.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import Foundation
@_exported import Path


public class File: FileSystemElement {
  public override init?(path: Path) {
    guard path.isFile else { return nil }
    super.init(path: path)
  }
}


public class FileSystemElement {
  public let path: Path
  
  public var url: URL {
    return path.url
  }
  
  public var name: String {
    return path.basename()
  }
  
  public var `extension`: String {
    return path.extension
  }
  
  public var exists: Bool {
    return path.exists
  }
  
  public init?(path: Path) {
    self.path = path
  }
      
  public convenience init?(path: String) {
    guard let path = Path(path) else { return nil }
    self.init(path: path)
  }
  
  public convenience init?(url: URL) {
    guard let path = Path(url: url) else { return nil }
    self.init(path: path)
  }
}


extension FileSystemElement: Hashable {
  public static func == (lhs: FileSystemElement, rhs: FileSystemElement) -> Bool {
    return lhs.path == rhs.path
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }
}


public extension URL {
  var file: File? {
    guard let path = Path(url: self) else { return nil }
    return File(path: path)
  }
  
  var mime: String {
    guard let mime = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else { return "" }
    return mime.takeRetainedValue() as String
  }
  
  var uti: String {
     if let resourceValues = try? resourceValues(forKeys: [.typeIdentifierKey]),
       let uti = resourceValues.typeIdentifier {
         return uti
     }
     return ""
   }
  
  func typeIdentifierConforms(to: String) -> Bool {
    return UTTypeConformsTo(uti as CFString , to as CFString)
  }    
}
