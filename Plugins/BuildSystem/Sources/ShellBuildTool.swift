//
//  DefaultShellBuildTool.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore


class ShellBuildTool: BuildTool {
  var name: String {
    return "Shell"
  }
  
  func run(in workbench: Workbench) -> BuildProgress {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return EmptyBuildProgress()
    }
    let shellProc = Process()
    shellProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    shellProc.executableURL = URL(fileURLWithPath: "/bin/sh")
    shellProc.arguments = [fileURL.path]
    try? shellProc.run()
    return EmptyBuildProgress()
  }
}


struct EmptyBuildProgress : BuildProgress {
  
}

