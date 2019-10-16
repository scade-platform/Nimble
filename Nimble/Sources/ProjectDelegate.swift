//
//  ProjectDelegate.swift
//  Nimble
//
//  Created by Danil Kristalev on 11/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class DefaultProjectDelegate: ProjectDelegate {
  
  func runSimulator(folder: Folder) {
    let console: Console?
    guard let toolchain = NimbleController.shared.toolchainPath else {
      return
    }
    if let consoleController = ConsoleManager.shared.controllerInstance() {
      console = consoleController.createConsole(title: "Simulator", show: true)
    } else {
      console = nil
    }
    let simulatorTask = Process()
    simulatorTask.currentDirectoryPath = "\(folder.path.string)/.build/scade-simulator"
    simulatorTask.executableURL = URL(fileURLWithPath: "\(toolchain)/bin/macos/PhoenixSimulator.app/Contents/MacOS/PhoenixSimulator")
    simulatorTask.arguments = ["\(folder.path.string)/products/TestProject.scadeapp"]
    if let console = console {
      simulatorTask.standardOutput = console.output
    }
    try! simulatorTask.run()
  }

  
  func build(folder: Folder) {
    if let workbench = (NimbleController.shared.currentDocument as? ProjectDocument)?.workbench, var debugArea = workbench.debugArea as? Hideable {
      debugArea.isHidden = false
    }
    cMakeRun(folder)
  }

  
  private func cMakeRun(_ folder: Folder) {
    let console: Console?
    if let consoleController = ConsoleManager.shared.controllerInstance()  {
      console = consoleController.createConsole(title: "CMake Run", show: true)
    } else {
      console = nil
    }
    
    guard let toolchain = NimbleController.shared.toolchainPath else {
      if let console = console {
        console.writeLine(string: "CMake didn't find.")
      }
      return
    }
    let cMakeTask = Process()
    cMakeTask.currentDirectoryPath = "\(folder.path.string)/.build/scade-simulator"
    cMakeTask.executableURL = URL(fileURLWithPath: "\(toolchain)/thirdparty/CMake.app/Contents/bin/cmake")
    cMakeTask.arguments = ["-DCMAKE_MODULE_PATH=\(toolchain)/cmake/modules", "-DCMAKE_TOOLCHAIN_FILE=\(toolchain)/cmake/toolchains/scadesdk.toolchain.cmake", "-DCMAKE_MAKE_PROGRAM=make", "-DSCADESDK_TARGET=macos", "-DCMAKE_BUILD_TYPE=Debug", "-Wno-dev", "\(folder.path.string)"]
    if let console = console {
      cMakeTask.standardOutput = console.output
    }
    cMakeTask.terminationHandler = { p in
      self.cMakeBuild(folder)
    }
    try! cMakeTask.run()
  }
  
  private func cMakeBuild(_ folder: Folder) {
    guard let toolchain = NimbleController.shared.toolchainPath else {
      return
    }
    let console: Console?
    if let consoleController = ConsoleManager.shared.controllerInstance()  {
      console = consoleController.createConsole(title: "Build", show: true)
    }else {
      console = nil
    }
    let buildTask = Process()
    buildTask.currentDirectoryURL = URL(fileURLWithPath: "\(folder.path.string)/.build/scade-simulator")
    buildTask.executableURL = URL(fileURLWithPath: "\(toolchain)/thirdparty/CMake.app/Contents/bin/cmake")
    buildTask.arguments = ["--build", "\(folder.path.string)/.build/scade-simulator"]
    if let console = console {
      buildTask.standardOutput = console.output
    }
    try! buildTask.run()
  }
}

