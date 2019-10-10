//
//  NimbleConsolePlugin.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public final class NimbleConsole: Module {
  public static var pluginClass: Plugin.Type = NimbleConsolePlugin.self
}

open class NimbleConsolePlugin: Plugin {
  required public init() {
    ConsoleManager.shared.registerControllerClass(NimbleConsoleViewController.self)
  }
  
  static var workbench: Workbench? = nil
  
  public func activate(workbench: Workbench) {
    NimbleConsolePlugin.workbench = workbench
    workbench.project?.delegate = ProjectBuilder()
  }
  
  public func deactivate() {
    
  }
}

class ProjectBuilder: ProjectDelegate {
  
  func build(project: Project) {
    guard let consoleController = ConsoleManager.shared.controllerInstance() else {
      return
    }
    let console = consoleController.createConsole(title: "Simulator", show: true)
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/.metadata/.plugins/com.scade.sdk.toolchain.nightly/Toolchain/bin/macos/PhoenixSimulator.app/Contents/MacOS/PhoenixSimulator")
    task.arguments = ["/Users/danilkristalev/Documents/Work/Scade/runtime-New_configuration/TestProject/products/TestProject.scadeapp"]
    task.standardOutput = console.input
    try! task.run()
    console.write(string: "Teeeesttt1").writeLine()
  }
  
}
