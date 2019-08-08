//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import Yams

public class Project {
  public var folders: [Folder] = []
  private let location: Path?
  private let name: String?
  
  init(_ url: URL?  = nil){
    if let url = url, let path = Path(url: url)  {
      location = path.parent
      name = path.basename(dropExtension: true)
    } else {
      location = nil
      name = nil
    }
  }
  
  public func addFolders(urls: [URL]){
    guard !urls.isEmpty else {
      return
    }
    urls.forEach{ addFolder($0.path) }
  }
  
  @discardableResult
  private func addFolder(_ folder: String) -> Bool {
    if let folderPath = Path(folder) {
      if !addFolder(folderPath) {
        return addRelativeFolder(folder)
      }
      return true
    }
    return addRelativeFolder(folder)
  }
  
  @discardableResult
  private func addFolder(_ folderPath: Path) -> Bool{
    guard folderPath.exists && folderPath.isDirectory else {
      return false
    }
    folders.append(Folder(path: folderPath))
    return true
    
  }
  
  @discardableResult
  private func addRelativeFolder(_ folder: String) -> Bool {
    guard let base = self.location else {
      return false
    }
    let absolutPath = base.join(folder)
    return addFolder(absolutPath)
  }
}


public class ProjectManager {
  public var currentProject: Project = Project()
  
  public static let shared: ProjectManager = ProjectManager()
  
  public func createProject(_ url : URL? = nil) -> Project {
    let newProject = Project(url)
    currentProject = newProject
    return newProject
  }
}

extension Project {
  public func read(from data: Data) -> [String]? {
    let yamlContent = String(bytes: data, encoding: .utf8)!
    guard !yamlContent.isEmpty else {
      return nil
    }
    let loadedDictionary = try? Yams.load(yaml: yamlContent) as! [String: [String]]
    if let loadedDictionary = loadedDictionary {
      var incorrectPaths = [String]()
      if let p = addFolders(loadedDictionary){
        incorrectPaths.append(contentsOf: p)
      }
      //TODO: add files
      if !incorrectPaths.isEmpty {
        return incorrectPaths
      }
    }
    return nil
  }
  
  private func addFolders(_ loadedDictionary: [String: [String]]) -> [String]? {
    guard let foldersPaths = loadedDictionary[caseInsensitive: "FOLDERS"] else {
      return nil
    }
    var incorrectPaths = [String]()
    for folderPath in foldersPaths {
      if !addFolder(folderPath){
        incorrectPaths.append(folderPath)
      }
    }
    if !incorrectPaths.isEmpty {
      return incorrectPaths
    }
    return nil
  }
  
  public func data() -> Data {
    return Data()
  }
}

private extension Dictionary where Key == String {
  
  subscript(caseInsensitive key: Key) -> Value? {
    get {
      if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
        return self[k]
      }
      return nil
    }
    set {
      if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
        self[k] = newValue
      } else {
        self[key] = newValue
      }
    }
  }
  
}
