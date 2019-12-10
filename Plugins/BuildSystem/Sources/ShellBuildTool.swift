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
      return ShellBuildProgress()
    }
    let shellProc = Process()
    shellProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    shellProc.executableURL = URL(fileURLWithPath: "/bin/sh")
    shellProc.arguments = [fileURL.path]
    try? shellProc.run()
    return ShellBuildProgress()
  }
  
  func canBuild(file url: URL) -> Bool {
    let fileExtension = url.pathExtension
    guard !fileExtension.isEmpty, fileExtension == "sh" else {
      return false
    }
    return true
  }
  
  func isDefault(for file: URL) -> Bool {
    return canBuild(file: file)
  }
}


struct ShellBuildProgress : BuildProgress {
  
}

