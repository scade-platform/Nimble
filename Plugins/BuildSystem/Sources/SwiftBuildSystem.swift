//
//  SwiftBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 10/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore

class SwiftBuildSystem: BuildSystem {
  var name: String {
    return "Swift File"
  }
  
  func run(in workbench: Workbench) -> BuildProgress {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return SwiftBuildProgress()
    }
    
    workbench.currentDocument?.save(nil)
    let swiftcProc = Process()
    swiftcProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    swiftcProc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    swiftcProc.arguments = [fileURL.path]
    var swiftcProcConsole: Console?
    swiftcProc.terminationHandler = { process in
      swiftcProcConsole?.stopReadingFromBuffer()
      let programProc = Process()
      programProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
      programProc.executableURL = URL(fileURLWithPath: "\(fileURL.deletingPathExtension())")
      var programProcConsole: Console?
      programProc.terminationHandler = { process in
        programProcConsole?.stopReadingFromBuffer()
      }
      DispatchQueue.main.async {
        programProcConsole = workbench.createConsole(title: "Run: \(fileURL.deletingPathExtension().lastPathComponent)", show: true)
        programProc.standardOutput = programProcConsole?.output
        programProc.standardError = programProcConsole?.output
        try? programProc.run()
      }
    }
    DispatchQueue.main.async {
      workbench.debugArea?.isHidden = false
      swiftcProcConsole = workbench.createConsole(title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", show: true)
      swiftcProc.standardError = swiftcProcConsole?.output
      try? swiftcProc.run()
    }
    
    return SwiftBuildProgress()
  }
}

struct SwiftBuildProgress : BuildProgress {
  
}
