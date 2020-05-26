//
//  Plugin.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 12.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import LSPClient
import SKLocalServer

public final class LSPClientModule: Module {
  public static let plugin: Plugin = LSPClientPlugin()
}


final class LSPClientPlugin: Plugin {
  func load() {
    Settings.shared.add(SKLocalServer.$swiftToolchain)
    Settings.shared.add(SKLocalServer.$swiftTarget)
    Settings.shared.add(SKLocalServer.$swiftSdkRoot)
    Settings.shared.add(SKLocalServer.$swiftCompilerFlags)
    LSPServerManager.shared.registerProvider(SKLocalServerProvider())
  }
  
  public func activate(in workbench: Workbench) {
    LSPServerManager.shared.connect(to: workbench)
  }
  
  public func deactivate(in workbench: Workbench) {
    LSPServerManager.shared.disconnect(from: workbench)
  }
}
