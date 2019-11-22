//
//  Folder.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//


public class Folder: FileSystemElement {
  
  //TODO: sorting, reloading/FS watchig etc.
  public var content: [FileSystemElement] {
    let subfolders = try? self.subfolders()
    let files = try? self.files()
    var result : [FileSystemElement] = subfolders ?? []
    result += files ?? []
    return result
  }
  
  public func subfolders() throws -> [Folder] {
    let directoryPaths = try self.path.ls().directories
    return directoryPaths.map{Folder(path: $0)}.sorted{$0.name.lowercased() < $1.name.lowercased()}
  }
  
  public func files() throws -> [File] {
    let filePaths = try self.path.ls().files
    return filePaths.filter{$0.basename() != ".DS_Store"}.map{File(path: $0)}.sorted{$0.name.lowercased() < $1.name.lowercased()}
  }
}
