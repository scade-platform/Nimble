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
    
    let swiftcProc = Process()
    swiftcProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    swiftcProc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    swiftcProc.arguments = [fileURL.path]
    swiftcProc.terminationHandler = { process in
      let programProc = Process()
      programProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
      programProc.executableURL = URL(fileURLWithPath: "\(fileURL.deletingPathExtension())")
      DispatchQueue.main.async {
        let console = workbench.createConsole(title: "Run: \(fileURL.deletingPathExtension().lastPathComponent)", show: true)
        programProc.standardOutput = console?.output
        programProc.standardError = console?.output
        try? programProc.run()
      }
    }
    DispatchQueue.main.async {
      workbench.debugArea?.isHidden = false
      let console = workbench.createConsole(title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", show: true)
      swiftcProc.standardError = console?.output
      try? swiftcProc.run()
    }
    
    return SwiftBuildProgress()
  }
}

struct SwiftBuildProgress : BuildProgress {
  
}