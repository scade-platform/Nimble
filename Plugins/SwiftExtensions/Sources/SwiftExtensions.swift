//
//  SwiftExtensions.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import BuildSystem

public final class SwiftExtensions: Module {
  public static let plugin: Plugin = SwiftExtensionsPlugin()
}


final class SwiftExtensionsPlugin: Plugin {
  func load() {
    BuildSystemsManager.shared.register(buildSystem: SwiftBuildSystem())
    BuildSystemsManager.shared.register(buildSystem: SPMBuildSystem())
  }
}

