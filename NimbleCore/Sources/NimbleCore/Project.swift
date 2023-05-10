//
//  Project.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@_implementationOnly import Yams


public final class Project {
  struct RawData: Codable {
    let folders: [String]?
  }
  
  public private(set) var path: Path?
  
  private var projectFolders: [ProjectFolder] {
    didSet {
      guard oldValue != projectFolders else {
        return
      }
      observers.notify {
        $0.projectFoldersDidChange(self)
      }      
    }
  }

  public weak var workbench: Workbench?

  public var url: URL? {
    set {
      guard let newValue = newValue else {
        path = nil
        return
      }
      path = Path(url: newValue)
    }
    get {
      path?.url
    }
  }
  
  public var folders: [Folder] {
    projectFolders.map {$0.folder}
  }
  
  public var observers = ObserverSet<ProjectObserver>()
  
  public var isEmpty: Bool {
    projectFolders.isEmpty && path == nil
  }
  
  public func data() -> Data? {
    let folders: [String] = self.projectFolders.map {
      if let relPath = $0.relativePath, let absPath = self.path?.join(relPath), absPath.exists {
        return relPath
      } else {
        return $0.folder.path.description
      }
    }
    let content = try? YAMLEncoder().encode(RawData(folders: folders))
    return content?.data(using: .utf8)
  }
  
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
    
    self.projectFolders.forEach{ projectFolder in
      projectFolder.folder.observers.add(observer: self)
    }
  }
  
  public func save(to path: Path) throws {
    guard let content = data() else {
      return
    }
    try content.write(to: path)
  }
  
  private func save() {
    guard let path = path else { return }
    do {
      try save(to: path)
    } catch {}
  }
  
  public func add(_ folder: Folder) {
    guard !projectFolders.contains(where: {$0.folder == folder}) else {
      //already contains this folder
      return
    }
    
    guard let path = self.path else {
      projectFolders.append(ProjectFolder(folder: folder))
      folder.observers.add(observer: self)
      return
    }
    
    // Check if the folder is from the project's sub-tree
    // If yes, store it relative to the project's file, otherwise absolute
    var relativePath: String? = nil
    if folder.path.description.starts(with: path.parent.description) {
      relativePath = folder.path.relative(to: path.parent)
    }

    projectFolders.append(ProjectFolder(folder: folder, relativePath: relativePath))
    folder.observers.add(observer: self)
  }
  
  public func remove(_ folder: Folder) {
    projectFolders.removeAll {
      if $0.folder == folder {
        $0.folder.isRoot = false
        $0.folder.observers.remove(observer: self)
        return true
      }
      return false
    }
  }
    
  public func folder(containing url: URL) -> Folder? {
    return folders.first {
      url.absoluteString.starts(with: $0.path.url.absoluteString)
    }
  }

}


fileprivate struct ProjectFolder: Equatable {
  let folder: Folder
  let relativePath: String?
  
  init(folder: Folder, relativePath: String? = nil) {
    self.folder = folder
    self.folder.isRoot = true
    self.relativePath = relativePath
  }
  
  init?(_ path: String, relativeTo root: Path? = nil) {
    guard let folder = Folder(path: path) else {
      guard let absolutePath = root?.join(path),
            let folder = Folder(path: absolutePath),
            folder.exists else { return nil }
      
      self.init(folder: folder, relativePath: path)
      return
    }
    self.init(folder: folder)
  }
}


public protocol ProjectObserver: AnyObject {
  func projectFoldersDidChange(_: Project)
}

public extension ProjectObserver {
  func projectFoldersDidChange(_: Project) {}
}

extension Project: FolderObserver {
  public func folderDidMoved(_ folder: Folder, to newPath: Path) {
    remove(folder)
    guard let newFolder = Folder(path: newPath) else {
      return
    }
    add(newFolder)
  }
}



