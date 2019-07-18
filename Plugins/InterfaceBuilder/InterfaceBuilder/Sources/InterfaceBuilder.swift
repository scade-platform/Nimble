//
//  InterfaceBuilder.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import ScadeKit


public final class InterfaceBuilder: Module {
  public static var pluginClass: Plugin.Type = InterfaceBuilderPlugin.self
}


open class InterfaceBuilderPlugin: Plugin {
  required public init() {
    DocumentManager.shared.registerDocumentClass(PageDocument.self)
    SCDRuntime.loadMetaModel()
    
  }
  
  public func activate(workbench: Workbench) {
    workbench.project.folders.forEach {
      UserDefaults.standard.set($0.path.string, forKey: "Resource Folder")
    }
  }
  
  public func deactivate() {
    
  }
}
