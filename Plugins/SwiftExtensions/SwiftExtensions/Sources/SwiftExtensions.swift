//
//  SwiftExtensions.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import CodeEditorCore

public final class SwiftExtensions: Module {
  public static var pluginClass: Plugin.Type = SwiftExtensionsPlugin.self
}


open class SwiftExtensionsPlugin: Plugin {
  required public init() {
    TextDocumentDelegateManager.shared.registerTextDocumentDelegate(SwiftDocumentDelegate.self, for: "swift")
  }
  
  public func activate(workbench: Workbench) {
    
  }
  
  public func deactivate() {
    
  }
}

