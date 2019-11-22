//
//  Folder.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//


public class Folder: FileSystemElement {
  public override init?(path: Path) {
    guard path.isDirectory else { return nil }
    super.init(path: path)
  }
  
  //TODO: sorting, reloading/FS watchig etc.
  public var content: [FileSystemElement] {
    let subfolders = try? self.subfolders()
    let files = try? self.files()
    var result : [FileSystemElement] = subfolders ?? []
    result += files ?? []
    return result
  }
  
  public func subfolders() throws -> [Folder] {
    let dirs = try self.path.ls().directories
    return dirs.compactMap{Folder(path: $0)}.sorted{$0.name.lowercased() < $1.name.lowercased()}
  }
  
  public func files() throws -> [File] {
    let files = try self.path.ls().files
    return files.filter{$0.basename() != ".DS_Store"}.compactMap{File(path: $0)}.sorted{$0.name.lowercased() < $1.name.lowercased()}
  }
}
