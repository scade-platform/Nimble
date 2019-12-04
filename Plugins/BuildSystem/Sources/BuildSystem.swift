//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 02/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import NimbleCore
import Cocoa

public final class BuildSystem: Module {
  public static var pluginClass: Plugin.Type = BuildSystemPlugin.self
}

public final class BuildSystemPlugin: Plugin {
  public init() {
    BuildToolsManager.shared.registerBuildToolClass(ShellBuildTool.self)
    
    //TODO: Remove this
    //simple of usage
    let config : [BuildConfigField: Any] = [.file: "/Users/danilkristalev/Desktop/tests/script.sh",
                                            .working_dir: "/Users/danilkristalev/Desktop/tests/"]
    guard let buildProc = try? ShellBuildTool.run(with: config) else { return }
    print(buildProc.isRunning)
    buildProc.cancel()
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      print(buildProc.isRunning)
    })
    
  }
}
