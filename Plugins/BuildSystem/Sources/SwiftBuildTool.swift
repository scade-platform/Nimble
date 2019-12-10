//
//  SwiftBuildTool.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 10/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore

class SwiftBuildTool: BuildTool {
  var name: String {
    return "Swift"
  }
  
  func run(in workbench: Workbench) -> BuildProgress {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return SwiftBuildProgress()
    }
    let console = workbench.createConsole(title: "\(fileURL.deletingPathExtension().lastPathComponent)", show: true)
    let swiftcProc = Process()
    swiftcProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    swiftcProc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    swiftcProc.arguments = [fileURL.path]
    swiftcProc.terminationHandler = { process in
      let programProc = Process()
      programProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
      programProc.executableURL = URL(fileURLWithPath: "\(fileURL.deletingPathExtension())")
      programProc.standardOutput = console?.output
      try? programProc.run()
    }
    try? swiftcProc.run()
    return SwiftBuildProgress()
  }
  
  func canBuild(file url: URL) -> Bool {
    let fileExtension = url.pathExtension
    guard !fileExtension.isEmpty, fileExtension == "swift" else {
      return false
    }
    return true
  }
  
  func isDefault(for file: URL) -> Bool {
    return canBuild(file: file)
  }
}

struct SwiftBuildProgress : BuildProgress {
  
}
