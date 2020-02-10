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
    return SwiftLauncher(builder: self)
  }()
  
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return
    }
    
    workbench.currentDocument?.save(nil)
    let swiftcProc = Process()
    swiftcProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    swiftcProc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    swiftcProc.arguments = [fileURL.path]
    var swiftcProcConsole: Console?
    swiftcProc.terminationHandler = { process in
      swiftcProcConsole?.stopReadingFromBuffer()
      if let contents = swiftcProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            swiftcProcConsole?.close()
          }
          self.updateAndRemoveStatus(currentStatus: "Building", newStatus: "Build done", newColor: .systemGreen, workbench: workbench)
          handler?(.finished)
        } else {
          DispatchQueue.main.async {
            workbench.debugArea?.isHidden = false
          }
          if contents.contains("error:"){
            self.updateAndRemoveStatus(currentStatus: "Building", newStatus: "Build failed", workbench: workbench)
            handler?(.failed)
          } else {
            self.updateAndRemoveStatus(currentStatus: "Building", newStatus: "Build done", newColor: .systemGreen, workbench: workbench)
            handler?(.finished)
          }
        }
      }
    }
    DispatchQueue.main.async {
      self.addStatus(status: "Building", color: .systemRed, workbench: workbench)
      swiftcProcConsole = self.openConsole(key: "Compile: \(fileURL.absoluteString)", title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
      swiftcProc.standardError = swiftcProcConsole?.output
      try? swiftcProc.run()
    }
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return
    }
    guard let file = File(url: fileURL.deletingPathExtension()), file.exists else { return }
    try? file.path.delete()
    self.addAndRemoveStatus(status: "Clean done", color: .systemGreen, workbench: workbench)
    handler?()
  }
}

extension SwiftBuildSystem : ConsoleSupport {}
extension SwiftBuildSystem : StatusBarSupport {}

class SwiftLauncher : Launcher {
  let builder : BuildSystem
  
  init(builder: BuildSystem) {
    self.builder = builder
  }
  
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    builder.run(in: workbench, handler: {status in
      switch status {
      case .finished:
        self.run(in: workbench, handler: handler)
      case .failed:
        handler?(.failed, nil)
      default: break
      }
    })
  }
  
  private func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    DispatchQueue.main.async {
      guard let fileURL = workbench.currentDocument?.fileURL else {
        self.addAndRemoveStatus(status: "Run failed", color: .systemRed, workbench: workbench)
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
      workbench.debugArea?.isHidden = false
      programProcConsole = self.openConsole(key: fileURL, title: "Run: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
      programProc.standardOutput = programProcConsole?.output
      programProc.standardError = programProcConsole?.output
      try? programProc.run()
      self.addAndRemoveStatus(status: "Running", color: .systemRed, workbench: workbench)
      handler?(.running, programProc)
    }
  }
}

extension SwiftLauncher : ConsoleSupport {}
extension SwiftLauncher : StatusBarSupport {}
