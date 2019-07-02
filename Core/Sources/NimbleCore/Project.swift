//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//


public class Project {
  //TODO: remove default home path, it's only for demo
  public var folders: [Folder] = [Folder(path: Path.home)]
}


public class ProjectManager {
  public var currentProject: Project = Project()
  
  public static let shared: ProjectManager = ProjectManager()
}
