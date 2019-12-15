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
    clean(file: fileURL)
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
  
  private func clean(file url: URL) {
    guard let file = File(url: url.deletingPathExtension()), file.exists else { return }
    try? file.path.delete()
  }
}

struct SwiftBuildProgress : BuildProgress {
  
}
