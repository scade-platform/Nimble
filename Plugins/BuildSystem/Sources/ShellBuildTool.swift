//
//  ShellBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore


class ShellBuildSystem: BuildSystem {
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
    DispatchQueue.main.async {
      let console = workbench.createConsole(title: "\(fileURL.lastPathComponent)", show: true)
      shellProc.standardOutput = console?.output
      shellProc.standardError = console?.output
      try? shellProc.run()
    }
    return ShellBuildProgress()
  }
}


struct ShellBuildProgress : BuildProgress {
  
}

