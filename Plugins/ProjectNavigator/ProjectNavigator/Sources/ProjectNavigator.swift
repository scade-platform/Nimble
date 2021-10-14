//
//  ProjectNavigator.swift
//  ProjectNavigator
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
