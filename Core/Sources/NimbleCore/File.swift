//
//  File.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

@_exported import Path


public class File: FileSystemElement { }


public class FileSystemElement {
  public let path: Path
  
  public var name: String {
    return path.basename()
  }
  
  public init(path: Path) {
    self.path = path
  }
  
  public convenience init?(path: String) {
    guard let path = Path(path) else { return nil }
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

