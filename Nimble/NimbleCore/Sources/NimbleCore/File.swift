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
  public private(set) var path: Path
  
  public var name: String {
    return path.basename()
  }
  
  public var `extension`: String {
    return path.extension
  }
  
  required public init(path: Path) {
    self.path = path
  }
  
  public convenience init?(path: String) {
    guard let path = Path(path) else { return nil }
    self.init(path: path)
  }
  
  public func rename(to name: String) {
    guard let newPaht = try? path.rename(to: name) else {
      return
    }
    self.path = newPaht
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
    guard let path = Path(url: self), path.isFile else { return nil }
    return File(path: path)
  }
}
