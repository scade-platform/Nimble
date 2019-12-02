//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 02/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import NimbleCore

public final class BuildSystem: Module {
  public static var pluginClass: Plugin.Type = BuildSystemPlugin.self
}

public final class BuildSystemPlugin: Plugin {
  public init() {}
}
