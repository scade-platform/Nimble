//
//  SwiftExtensions.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import BuildSystem
import LSPClient
import SwiftExtensions

public final class SwiftExtensionsModule: Module {
  public static let plugin: Plugin = SwiftExtensionsPlugin()
}


final class SwiftExtensionsPlugin: Plugin {

  func load() {
    Settings.shared.add(SKLocalServer.$swiftToolchain)

    LSPServerManager.shared.registerProvider(SKLocalServerProvider())

    BuildSystemsManager.shared.register(buildSystem: SwiftBuildSystem())
    BuildSystemsManager.shared.register(buildSystem: SPMBuildSystem())

    Settings.shared.add(SPMBuildSystem.$toolchains)
  }
}

