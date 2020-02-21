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
  
  lazy var launcher: Launcher? = {
    return SwiftLauncher()
  }()
  
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?) {
    workbench.currentDocument?.save(nil)
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return
    }
    
    let swiftcProc = Process()
    swiftcProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    swiftcProc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    swiftcProc.arguments = [fileURL.path, "-Xfrontend", "-color-diagnostics"]
    
    var swiftcProcConsole: Console?
    
    swiftcProc.terminationHandler = { process in
      swiftcProcConsole?.stopReadingFromBuffer()
      
      if let contents = swiftcProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            swiftcProcConsole?.close()
          }
          handler?(.finished)
        } else {
          if contents.contains("error:"){
            handler?(.failed)
          } else {
            handler?(.finished)
          }
        }
      }
    }
    
    swiftcProcConsole = self.openConsole(key: "Compile: \(fileURL.absoluteString)", title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
    swiftcProc.standardOutput = swiftcProcConsole?.output
    swiftcProc.standardError = swiftcProcConsole?.output
    try? swiftcProc.run()
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return
    }
    guard let file = File(url: fileURL.deletingPathExtension()), file.exists else { return }
    try? file.path.delete()
    handler?()
  }
}

extension SwiftBuildSystem : ConsoleSupport {}

class SwiftLauncher : Launcher {
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      handler?(.failed, nil)
      return
    }
    let programProc = Process()
    programProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    programProc.executableURL = URL(fileURLWithPath: "\(fileURL.deletingPathExtension())")
    var programProcConsole: Console?
    programProc.terminationHandler = { process in
      programProcConsole?.stopReadingFromBuffer()
      handler?(.finished, process)
    }
    programProcConsole = self.openConsole(key: fileURL, title: "Run: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
    programProc.standardOutput = programProcConsole?.output
    programProc.standardError = programProcConsole?.output
    try? programProc.run()
    handler?(.running, programProc)
  }
}
extension SwiftLauncher : ConsoleSupport {}
