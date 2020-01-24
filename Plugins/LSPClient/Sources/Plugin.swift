//
//  Plugin.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 12.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore


public final class LSPClientModule: Module {
  public static let plugin: Plugin = LSPClientPlugin()
}


final class LSPClientPlugin: Plugin {
  func activate(in workbench: Workbench) {
    LSPServerManager.shared.connect(to: workbench)
  }
  
  func deactivate(in workbench: Workbench) {
    LSPServerManager.shared.disconnect(from: workbench)
  }
}