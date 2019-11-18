//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Yams

public final class Project {
  struct RawData: Codable {
    let folders: [String]?
  }
  
  public private(set) var path: Path?
  
  private var projectFolders: [ProjectFolder] {
    didSet {
      observers.notify {
        $0.projectFoldersDidChange(self)
      }
    }
  }
  
  public var folders: [Folder] {
    projectFolders.map {$0.folder}
  }
  
  public var observers = ObserverSet<ProjectObserver>()
    
  public init() {
    self.path = nil
    self.projectFolders = []
  }
  
  public func load(from path: Path) throws {
    let content = try String(contentsOf: path)
    let rawData = try YAMLDecoder().decode(RawData.self, from: content)
            
    self.path = path
    self.projectFolders = (rawData.folders ?? []).compactMap {
      ProjectFolder($0, relativeTo: path.parent)
    }
  }
  
  public func save(to path: Path) throws {
    let folders: [String] = self.projectFolders.map {
      if let relPath = $0.relativePath, let absPath = self.path?.join(relPath), absPath.exists {
        return relPath
      } else {
        return $0.folder.path.description
      }
    }
    
    let content = try YAMLEncoder().encode(RawData(folders: folders))
    try content.write(to: path)
  }
  
  public func add(_ folder: Folder) {
    guard let path = self.path else {
      projectFolders.append(ProjectFolder(folder: folder))
      return
    }
    
    // Check if the folder is from the project's sub-tree
    // If yes, store it relative to the project's file, otherwise absolute
    var relativePath: String? = nil
    if folder.path.description.starts(with: path.description) {
      relativePath = folder.path.relative(to: path)
    }

    projectFolders.append(ProjectFolder(folder: folder, relativePath: relativePath))
  }
  
  public func remove(_ folder: Folder) {
    projectFolders.removeAll {
      $0.folder == folder
    }
  }
}


fileprivate struct ProjectFolder {
  let folder: Folder
  let relativePath: String?
  
  init(folder: Folder, relativePath: String? = nil) {
    self.folder = folder
    self.relativePath = relativePath
  }
  
  init?(_ path: String, relativeTo root: Path? = nil) {
    guard let folder = Folder(path: path) else {
      guard let absolutePath = root?.join(path), absolutePath.exists else { return nil }
      self.init(folder: Folder(path: absolutePath), relativePath: path)
      return
    }
    self.init(folder: folder)
  }
}


public protocol ProjectObserver: class {
  func projectFoldersDidChange(_: Project)
}





