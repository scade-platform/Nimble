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
  private var simulatorTask: Process?
  
  func runSimulator(project: Project) {
    stopSimulator(project: project)
    let console: Console?
    if let consoleController = ConsoleManager.shared.controllerInstance() {
      console = consoleController.createConsole(title: "Simulator", show: true)
    } else {
      console = nil
    }
    simulatorTask = Process()
    simulatorTask!.executableURL = URL(fileURLWithPath: "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/.metadata/.plugins/com.scade.sdk.toolchain.nightly/Toolchain/bin/macos/PhoenixSimulator.app/Contents/MacOS/PhoenixSimulator")
    simulatorTask!.arguments = ["/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/TestProject/products/TestProject.scadeapp"]
    if let console = console {
       simulatorTask!.standardOutput = console.output
    }
    try! simulatorTask!.run()
  }
  
  func stopSimulator(project: Project) {
    if simulatorTask?.isRunning ?? false {
      simulatorTask?.terminate()
    }
  }
  
  func runCMake(project: Project) {
    let console: Console?
    if let consoleController = ConsoleManager.shared.controllerInstance()  {
      console = consoleController.createConsole(title: "Run CMake", show: true)
    }else {
      console = nil
    }
    let cMakeTask = Process()
    cMakeTask.currentDirectoryURL = URL(fileURLWithPath: "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/TestProject/.build/scade-simulator")
    cMakeTask.executableURL = URL(fileURLWithPath: "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/.metadata/.plugins/com.scade.sdk.toolchain.nightly/Toolchain/thirdparty/CMake.app/Contents/bin/cmake")
    cMakeTask.arguments = ["-DCMAKE_MODULE_PATH=/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/.metadata/.plugins/com.scade.sdk.toolchain.nightly/Toolchain/cmake/modules", "-DCMAKE_TOOLCHAIN_FILE=/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/.metadata/.plugins/com.scade.sdk.toolchain.nightly/Toolchain/cmake/toolchains/scadesdk.toolchain.cmake", "-DCMAKE_MAKE_PROGRAM=make", "-DSCADESDK_TARGET=macos", "-DCMAKE_BUILD_TYPE=Debug", "-Wno-dev", "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/TestProject"]
    if let console = console {
      cMakeTask.standardOutput = console.output
    }
    cMakeTask.terminationHandler = { p in
      self.build(project: project)
    }
    try! cMakeTask.run()
    
  }
  
  func build(project: Project) {
    let console: Console?
    if let consoleController = ConsoleManager.shared.controllerInstance()  {
      console = consoleController.createConsole(title: "Build", show: true)
    }else {
      console = nil
    }
    let buildTask = Process()
    buildTask.executableURL = URL(fileURLWithPath: "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/.metadata/.plugins/com.scade.sdk.toolchain.nightly/Toolchain/thirdparty/CMake.app/Contents/bin/cmake")
    buildTask.arguments = ["--build", "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/TestProject/.build/scade-simulator"]
    buildTask.currentDirectoryURL = URL(fileURLWithPath: "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/TestProject/.build/scade-simulator")
    if let console = console {
      buildTask.standardOutput = console.output
    }
    try! buildTask.run()
  }
}
