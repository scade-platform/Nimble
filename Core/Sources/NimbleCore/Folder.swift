//
//  Folder.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//


public class Folder: FileSystemElement {
  
  //TODO: sorting, reloading/FS watchig etc.
  public lazy var content: [FileSystemElement]? = {
    return try? path.ls().compactMap {
      switch $0.kind {
      case .file:
        if $0.path.basename() == ".DS_Store" {
          return nil
        }
        return File(path: $0.path)
      default:
        return Folder(path: $0.path)
      }
    }.sorted{
      if type(of: $0) == type(of: $1) {
        return $0.name.lowercased() < $1.name.lowercased()
      } else {
        return $0 is Folder
      }
    }
  }()
}
