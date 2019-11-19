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


public final class ProjectNavigatorPlugin: Plugin {
  public init() { }
  
  public func activate(in workbench: Workbench) {
    // Create an instance every time it's activated in a workbench
    // An app can have multiple windows and hence multiple workbenches
    // NOTE: store on the plugin level carefully (there is ONE instance of the plugin,
    // that can be activated and disactivated multiple times within different workbenches)
    
    let outlineView = OutlineViewController.loadFromNib()
    outlineView.workbench = workbench
    workbench.navigatorArea?.add(part: outlineView)
  }
}
