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
  static var name: String {
    return "Shell"
  }
  
  static func run(with config: [BuildConfigField : Any]) throws -> BuildProcess? {
    guard let file = config[.file] as? String,
          let working_dir = config[.working_dir] as? String
    else { return nil }
    let shellProc = Process()
    shellProc.currentDirectoryPath = working_dir
    shellProc.executableURL = URL(fileURLWithPath: "/bin/sh")
    shellProc.arguments = [file]
    let result = SimpleBuildProcess(process: shellProc)
    try shellProc.run()
    return result
  }
}

struct SimpleBuildProcess : BuildProcess {
  let process: Process
  
  public var isRunning: Bool {
    return process.isRunning
  }
  
  public func cancel() {
    process.terminate()
  }
}
