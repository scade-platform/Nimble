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
  
  func run(in workbench: Workbench) -> BuildProgress {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return SwiftBuildProgress(status: .failure)
    }
    
    workbench.currentDocument?.save(nil)
    let swiftcProc = Process()
    swiftcProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    swiftcProc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    swiftcProc.arguments = [fileURL.path]
    var swiftcProcConsole: Console?
    var progress = SwiftBuildProgress()
    swiftcProc.terminationHandler = { process in
      swiftcProcConsole?.stopReadingFromBuffer()
      if let contents = swiftcProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            swiftcProcConsole?.close()
          }
        } else {
          DispatchQueue.main.async {
            workbench.debugArea?.isHidden = false
          }
          if contents.contains("error:"){
            progress.status = .failure
          }
        }
        progress.status = .finished
        let cell = StatusBarTextCell(title: "Build done.")
        DispatchQueue.main.async {
          var statusBar = workbench.statusBar
          if !statusBar.leftBar.contains(where: {$0.title == cell.title}) {
            statusBar.leftBar.append(cell)
          }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
          var statusBar = workbench.statusBar
          if statusBar.leftBar.contains(where: {$0.title == cell.title}) {
            if let index = statusBar.leftBar.firstIndex(where: {$0.title == cell.title}) {
              statusBar.leftBar.remove(at: index)
            }
          }
        }
      }
    }
    DispatchQueue.main.async {
      swiftcProcConsole = self.openConsole(key: "Compile: \(fileURL.absoluteString)", title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
      swiftcProc.standardError = swiftcProcConsole?.output
      try? swiftcProc.run()
    }
    return progress
  }
}

class SwiftBuildProgress : MutableBuildProgressImpl {
}

extension SwiftBuildSystem : ConsoleSupport {}

class SwiftLauncher : Launcher {
  let builder : BuildSystem
  
  init(builder: BuildSystem) {
    self.builder = builder
  }
  
  func launch(in workbench: Workbench) -> Process? {
    var buildProgress = builder.run(in: workbench)
       switch buildProgress.status {
       case .running:
         var process: Process?
         buildProgress.subscribe(handler: {[weak self] status in
           if status == .finished {
             process = self?.run(in: workbench)
           }
         })
         return process
       case .finished:
         return self.run(in: workbench)
       case .failure:
         return nil
       }
  }
  
  private func run(in workbench: Workbench) -> Process? {
    var programProc: Process? = Process()
    DispatchQueue.main.async {
      guard let fileURL = workbench.currentDocument?.fileURL else {
        programProc = nil
        return
      }
      programProc?.currentDirectoryURL = fileURL.deletingLastPathComponent()
      programProc?.executableURL = URL(fileURLWithPath: "\(fileURL.deletingPathExtension())")
      var programProcConsole: Console?
      programProc?.terminationHandler = { process in
        programProcConsole?.stopReadingFromBuffer()
      }
      workbench.debugArea?.isHidden = false
      programProcConsole = self.openConsole(key: fileURL, title: "Run: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
      programProc?.standardOutput = programProcConsole?.output
      programProc?.standardError = programProcConsole?.output
      try? programProc?.run()
    }
    return programProc
  }
}

extension SwiftLauncher : ConsoleSupport {}
