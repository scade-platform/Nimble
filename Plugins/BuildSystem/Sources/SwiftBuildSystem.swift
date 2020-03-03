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
  
  func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
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
      swiftcProcConsole?.writeLine(string: "Finished building \(fileURL.path)")
      swiftcProcConsole?.stopReadingFromBuffer()
      
      if let contents = swiftcProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            swiftcProcConsole?.close()
          }
          handler?(.finished, process)
        } else {
          if contents.contains("error:"){
            handler?(.failed, process)
          } else {
            handler?(.finished, process)
          }
        }
      }
    }
    
    swiftcProcConsole = self.openConsole(key: "Compile: \(fileURL.relativeString)", title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
    if !(swiftcProcConsole?.isReadingFromBuffer ?? true) {
      swiftcProc.standardOutput = swiftcProcConsole?.output
      swiftcProc.standardError = swiftcProcConsole?.output
      swiftcProcConsole?.startReadingFromBuffer()
      swiftcProcConsole?.writeLine(string: "Building: \(fileURL.path)")
    } else {
      //The console is using by another process with the same representedObject
      return
    }
    
    try? swiftcProc.run()
    handler?(.running, swiftcProc)
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return
    }
    let cleanConsole = self.openConsole(key: fileURL.appendingPathComponent("clean"), title: "Clean: \(fileURL.lastPathComponent)", in: workbench)
    guard let file = File(url: fileURL.deletingPathExtension()), file.exists else {
      cleanConsole?.startReadingFromBuffer()
      cleanConsole?.writeLine(string: "File not found: \(fileURL.deletingPathExtension().path)")
      cleanConsole?.stopReadingFromBuffer()
      return
    }
    try? file.path.delete()
    cleanConsole?.startReadingFromBuffer()
    cleanConsole?.writeLine(string: "File deleted: \(fileURL.deletingPathExtension().path)")
    cleanConsole?.stopReadingFromBuffer()
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
    if !(programProcConsole?.isReadingFromBuffer ?? true) {
      programProc.standardOutput = programProcConsole?.output
      programProc.standardError = programProcConsole?.output
      programProcConsole?.startReadingFromBuffer()
    } else {
      //The console is using by another process with the same representedObject
      return
    }
    try? programProc.run()
    handler?(.running, programProc)
  }
}
extension SwiftLauncher : ConsoleSupport {}
