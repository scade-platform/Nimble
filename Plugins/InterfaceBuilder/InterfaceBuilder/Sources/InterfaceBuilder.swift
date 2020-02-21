//
//  InterfaceBuilder.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import Foundation

public final class InterfaceBuilder: Module {
  public static let plugin: Plugin = InterfaceBuilderPlugin()
}

final class InterfaceBuilderPlugin: Plugin {
  func load() {
    DocumentManager.shared.registerDocumentClass(PageDocument.self)
  }
  
  public func activate(in workbench: Workbench) {
    ///TODO: do this every time a project from the workbench has been changed
    
    workbench.project?.folders.forEach {
      UserDefaults.standard.set($0.path.string, forKey: "Resource Folder")
    }
  }
  
  // public func deactivate(in workbench: Workbench) {
  //   ///TODO: remove defaults
  // }
}
