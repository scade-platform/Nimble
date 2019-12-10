//
//  AutomaticBuildTool.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 10/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore


class AutomaticBuildTool: BuildTool {
  public static let shared = AutomaticBuildTool()
  
  private init() {}
  
  var name: String {
    return "Automatic"
  }
  
  func run(in workbench: Workbench) -> BuildProgress {
    guard let fileURL = workbench.currentDocument?.fileURL, let tool = buildTool(for: fileURL) else {
      return AutomaticBuildProgress()
    }
    return tool.run(in: workbench)
  }
  
  private func buildTool(for file: URL) -> BuildTool? {
    var buildTool: BuildTool? = nil
    let tools = BuildToolsManager.shared.tools
    for tool in tools {
      if tool.canBuild(file: file) {
        buildTool = tool
      }
      if tool.isDefault(for: file) {
        break
      }
    }
    return buildTool
  }
}

struct AutomaticBuildProgress : BuildProgress {
  
}
