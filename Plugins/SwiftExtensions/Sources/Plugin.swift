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
    LSPServerManager.shared.registerProvider(SKLocalServerProvider())

    BuildSystemsManager.shared.register(buildSystem: SwiftBuildSystem())
    BuildSystemsManager.shared.register(buildSystem: SPMBuildSystem())

    WizardsManager.shared.register(wizard: SPMWizard())

    registerSettings()
  }

  public func activate(in workbench: Workbench) {
    SwiftLanguageService.shared.connect(to: workbench)
  }

  public func deactivate(in workbench: Workbench) {
    SwiftLanguageService.shared.disconnect(from: workbench)
  }

  private func registerSettings() {
    Settings.shared.add(SKLocalServer.$swiftToolchain)
    Settings.shared.add(SPMBuildSystem.$androidToolchainSdk)
    Settings.shared.add(SPMBuildSystem.$androidToolchainNdk)
    Settings.shared.add(SPMBuildSystem.$androidSwiftCompiler)
    Settings.shared.add(SPMBuildSystem.$platforms)
  }
}

