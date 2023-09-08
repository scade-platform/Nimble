//
//  ShellBuildSystem.swift
//  BuildSystem
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

import NimbleCore
import BuildSystem

class ShellBuildSystem: BuildSystem {
  var name: String {
    return "Shell"
  }
  
  func collectTargets(workbench: Workbench) -> TargetGroup {
    //TODO: add get Targets logic
    return TargetGroup(buildSystem: self, name: "Shell")
  }

  
  func run(_ variant: Variant) {
    //TODO: add launch logic
  }
  
  func build(_ variant: Variant) {
    //TODO: add build logic
  }
  
  func clean(_ variant: Variant) {
    //TODO: add clean logic
  }
  
}
  
//  func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
//    guard let fileURL = workbench.currentDocument?.fileURL else {
//      return
//    }
//    let shellProc = Process()
//    shellProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
//    shellProc.executableURL = URL(fileURLWithPath: "/bin/sh")
//    shellProc.arguments = [fileURL.path]
//    DispatchQueue.main.async {
//      let console = workbench.createConsole(title: "\(fileURL.lastPathComponent)", show: true)
//      shellProc.standardOutput = console?.output
//      shellProc.standardError = console?.output
//      try? shellProc.run()
//    }
//  }
//
//  func clean(in workbench: Workbench, handler: (() -> Void)?) {
//    handler?()
//  }
//}
//
//extension ShellBuildSystem : Launcher {
//  var builder: BuildSystem? {
//    return self
//  }
//
//  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
//    run(in: workbench)
//  }
//}
//
//
//
