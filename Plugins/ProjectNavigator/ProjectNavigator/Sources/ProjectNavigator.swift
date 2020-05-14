//
//  ProjectNavigator.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 02.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import Cocoa


public final class ProjectNavigator: Module {
  public static let plugin: Plugin = ProjectNavigatorPlugin()
}


final class ProjectNavigatorPlugin: Plugin {
  func load() {
    ContextMenuManager.shared.registerContextMenuProvider(ContextOutlineView.self)
  }
  
  public func activate(in workbench: Workbench) {
    // Create an instance every time it's activated in a workbench
    // An app can have multiple windows and hence multiple workbenches
    // NOTE: store on the plugin level carefully (there is ONE instance of the plugin,
    // that can be activated and disactivated multiple times within different workbenches)
    
    let outlineView = OutlineView.loadFromNib()
    outlineView.workbench = workbench
    workbench.navigatorArea?.add(part: outlineView)
  }
  
  func encodeRestorableState(in workbench: Workbench, coder: NSCoder) {
    guard let outlinePart = workbench.navigatorArea?.parts.first(where: {$0 is OutlineView}), let outlineView = outlinePart as? NSViewController else {
      return
    }
    outlineView.encodeRestorableState(with: coder)
  }
  
  func restoreState(in workbench: Workbench, coder: NSCoder) {
    guard let outlinePart = workbench.navigatorArea?.parts.first(where: {$0 is OutlineView}), let outlineView = outlinePart as? NSViewController else {
      return
    }
    outlineView.restoreState(with: coder)
  }
}
