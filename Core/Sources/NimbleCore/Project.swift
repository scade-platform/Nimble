//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//


public class Project {
  public var folders: [Folder] = []
}


public class ProjectManager {
  public var currentProject: Project = Project()
  
  public static let shared: ProjectManager = ProjectManager()
}
