//
//  File.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import Foundation
@_exported import Path


public class File: FileSystemElement { }


public class FileSystemElement {
  public let path: Path
  
  public var name: String {
    return path.basename()
  }
  
  public var `extension`: String {
    return path.extension
  }
  
  public init(path: Path) {
    self.path = path
  }
      
  public init?(path: String) {
    guard let path = Path(path) else { return nil }
    self.path = path
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
}
