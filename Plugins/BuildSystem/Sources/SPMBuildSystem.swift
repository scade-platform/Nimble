//
//  SPMBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 12/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore

class SPMBuildSystem: BuildSystem {
  var name: String {
    return "Swift Package"
  }
  
  lazy var launcher: Launcher? = {
    return SPMLauncher()
  }()
  
  
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?) {
    workbench.currentDocument?.save(nil)
    guard let curProject = workbench.project, let package = findPackage(project: curProject) else { return  }
    
    let fileURL = package.url
    
    let spmProc = Process()
    spmProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    spmProc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
    spmProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    spmProc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics"]
    
    var spmProcConsole : Console?
    
    spmProc.terminationHandler = { process in
      
      spmProcConsole?.stopReadingFromBuffer()

      
      if let contents = spmProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            spmProcConsole?.close()
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
    
    spmProcConsole = self.openConsole(key: fileURL, title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
    spmProc.standardOutput = spmProcConsole?.output
    spmProc.standardError = spmProcConsole?.output
    try? spmProc.run()
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return
    }
    
    let proc = Process()
    proc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    proc.arguments = ["package", "clean"]
    proc.terminationHandler = { process in
      handler?()
    }
    
    try? proc.run()
  }
}

extension SPMBuildSystem : ConsoleSupport {}

class SPMLauncher: Launcher {
  
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    guard let curProject = workbench.project, let package = findPackage(project: curProject) else {
      handler?(.failed, nil)
      return
    }
    let packageUrl = package.url
      
    let programProc = Process()
    programProc.currentDirectoryURL = packageUrl.deletingLastPathComponent()
    programProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    programProc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
    //we skip build because we always build before run
    programProc.arguments = ["run", "--skip-build"]
    
    var programProcConsole: Console?
    programProc.terminationHandler = { process in
      programProcConsole?.stopReadingFromBuffer()
      handler?(.finished, process)
    }
    
    let name = packageUrl.deletingLastPathComponent().lastPathComponent
    programProcConsole = openConsole(key: package, title: "Run: \(name)", in: workbench)
    programProc.standardOutput = programProcConsole?.output
    programProc.standardError = programProcConsole?.output
    
    try? programProc.run()
    handler?(.running, programProc)
  }
}

extension SPMLauncher : ConsoleSupport {}


fileprivate func findPackage(project: Project) -> File? {
  for folder in project.folders {
    guard let files = try? folder.files() else { continue }
    if let package = files.first(where: {file in file.name.lowercased() == "package.swift"}) {
      return package
    }
  }
  return nil
}
