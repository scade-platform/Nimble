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
  
  public static let MENU_ID = "com.scade.nimble.plugin.projectNavigator"
  
  public static var menBuilder : MenuBuilder {
    return ContextMenuManager.shared.menuBuilders[MENU_ID]!
  }
  
  private var navigatorPart: ProjectNavigatorPart
  
  required public init() {
    navigatorPart = ProjectNavigatorPart()
  }
  
  public func activate(workbench: Workbench) {
    workbench.navigatorArea?.add(part: navigatorPart)
    DocumentManager.shared.registerOpenableUTI(ofTypes: ["public.folder", "public.text"])
    workbench.projectNotificationCenter?.addProjectObserver(navigatorPart)
    workbench.addWorkbenchObserver(navigatorPart)
    navigatorPart.workbench = workbench
    let menuBuilder = ProjectNavigatorMenuBuilder(workbench: workbench)
    ContextMenuManager.shared.registerMenuBulder(id: ProjectNavigatorPlugin.MENU_ID, builder: menuBuilder)
  }
  
  public func deactivate() {
    
  }
  
}
