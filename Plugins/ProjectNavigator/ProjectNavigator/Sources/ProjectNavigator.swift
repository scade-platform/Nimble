//
//  ProjectNavigator.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 02.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore


public final class ProjectNavigator: Module {
  public static var pluginClass: Plugin.Type = ProjectNavigatorPlugin.self
}



open class ProjectNavigatorPlugin: Plugin {
  
  private var navigatorPart: ProjectNavigatorPart
  
  required public init() {
    navigatorPart = ProjectNavigatorPart()
  }
  
  public func activate(workbench: Workbench) {
    workbench.navigatorArea?.add(part: navigatorPart)
    ProjectManager.shared.subscribe(projectObserver: navigatorPart)
    workbench.project.subscribe(resourceObserver: navigatorPart)
    navigatorPart.workbench = workbench
  }
  
  public func deactivate() {
    
  }
  
}
