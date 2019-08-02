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
}

extension Project{
  public func read(from data: Data){
    let yamlContent = String(bytes: data, encoding: .utf8)!
    let loadedDictionary = try? Yams.load(yaml: yamlContent) as! [String: [String]]
    if let loadedDictionary = loadedDictionary, let foldersPaths = loadedDictionary["Folders"] {
      folders = foldersPaths.map{Folder(path: $0)!}
    }
  }
  
  public func data() -> Data? {
    return Data()
  }
}
