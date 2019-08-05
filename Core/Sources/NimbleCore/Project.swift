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
  //TODO: remove default home path, it's only for demo
  public var folders: [Folder] = []
}


public class ProjectManager {
  public var currentProject: Project = Project()
  

  public static let shared: ProjectManager = ProjectManager()
  
  public func createProject() -> Project {
    let newProject = Project()
    currentProject = newProject
    return newProject
  }
}

extension Project{
  public func read(from data: Data) -> [String]? {
    let yamlContent = String(bytes: data, encoding: .utf8)!
    guard !yamlContent.isEmpty else {
      return nil
    }
    let loadedDictionary = try? Yams.load(yaml: yamlContent) as! [String: [String]]
    if let loadedDictionary = loadedDictionary, let foldersPaths = loadedDictionary["Folders"] {
      var incorrectPaths = [String]()
      for folderPath in foldersPaths {
        if let folder = Folder(path: folderPath) {
          if folder.path.exists{
            folders.append(folder)
          } else {
            incorrectPaths.append(folderPath)
          }
        }
      }
      if !incorrectPaths.isEmpty {
         return incorrectPaths
      }
    }
    return nil
  }
  
  public func data() -> Data {
    return Data()
  }
}
