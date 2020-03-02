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
  
  
  func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
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
      spmProcConsole?.writeLine(string: "Finished building  \(fileURL.deletingLastPathComponent().lastPathComponent)")
      spmProcConsole?.stopReadingFromBuffer()

      
      if let contents = spmProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            spmProcConsole?.close()
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
    
    spmProcConsole = self.openConsole(key: fileURL.appendingPathComponent("compile"), title: "Compile: \(fileURL.deletingLastPathComponent().lastPathComponent)", in: workbench)
    if !(spmProcConsole?.isReadingFromBuffer ?? true) {
      spmProc.standardOutput = spmProcConsole?.output
      spmProc.standardError = spmProcConsole?.output
      spmProcConsole?.startReadingFromBuffer()
      spmProcConsole?.writeLine(string: "Building: \(fileURL.deletingLastPathComponent().lastPathComponent)")
    } else {
      //The console is using by another process with the same representedObject
      return
    }
    try? spmProc.run()
    handler?(.running, spmProc)
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let curProject = workbench.project, let package = findPackage(project: curProject) else { return  }
    
    
    let proc = Process()
    proc.currentDirectoryURL = package.url.deletingLastPathComponent()
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
    programProc.arguments = ["run", "--skip-build"]
    
    var programProcConsole: Console?
    programProc.terminationHandler = { process in
      programProcConsole?.stopReadingFromBuffer()
      handler?(.finished, process)
    }
    
    let name = packageUrl.deletingLastPathComponent().lastPathComponent
    programProcConsole = openConsole(key: package, title: "Run: \(name)", in: workbench)
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
