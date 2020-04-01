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
    guard let project = workbench.project, let package = findPackage(project: project) else { return  }
    
    let packageURL = package.url
    
    let spmProc = Process()
    spmProc.currentDirectoryURL = packageURL.deletingLastPathComponent()
    spmProc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
    spmProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    spmProc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics"]
    
    var spmProcConsole : Console?
    
    spmProc.terminationHandler = { process in
      spmProcConsole?.writeLine(string: "Finished building \(packageURL.deletingLastPathComponent().lastPathComponent)")
      spmProcConsole?.stopReadingFromBuffer()

      
      if let contents = spmProcConsole?.contents {
        if contents.isEmpty {
          DispatchQueue.main.async {
            spmProcConsole?.close()
          }
          handler?(.finished(workbench), process)
        } else {
          if contents.contains("error:"){
            handler?(.failed(workbench), process)
          } else {
            handler?(.finished(workbench), process)
          }
        }
      }
    }
    
    spmProcConsole = self.openConsole(key: packageURL.appendingPathComponent("compile"), title: "Compile: \(packageURL.deletingLastPathComponent().lastPathComponent)", in: workbench)
    if !(spmProcConsole?.isReadingFromBuffer ?? true) {
      spmProc.standardOutput = spmProcConsole?.output
      spmProc.standardError = spmProcConsole?.output
      spmProcConsole?.startReadingFromBuffer()
      spmProcConsole?.writeLine(string: "Building: \(packageURL.deletingLastPathComponent().lastPathComponent)")
    } else {
      //The console is using by another process with the same representedObject
      return
    }
    try? spmProc.run()
    handler?(.running(workbench), spmProc)
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let project = workbench.project, let package = findPackage(project: project) else { return  }
    
    let proc = Process()
    proc.currentDirectoryURL = package.url.deletingLastPathComponent()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    proc.arguments = ["package", "clean"]
    var cleanConsole : Console?
    proc.terminationHandler = { process in
      cleanConsole?.writeLine(string: "Finished Cleaning \(package.url.deletingLastPathComponent().lastPathComponent)")
      cleanConsole?.stopReadingFromBuffer()
      
      handler?()
    }
    cleanConsole = self.openConsole(key: package.url.appendingPathComponent("clean"), title: "Clean: \(package.url.deletingLastPathComponent().lastPathComponent)", in: workbench)
    
    if !(cleanConsole?.isReadingFromBuffer ?? true) {
      proc.standardOutput = cleanConsole?.output
      proc.standardError = cleanConsole?.output
      cleanConsole?.startReadingFromBuffer()
      cleanConsole?.writeLine(string: "Cleaning: \(package.url.deletingLastPathComponent().lastPathComponent)")
    } else {
      return
    }
    try? proc.run()
  }
  
  func canHandle(folder: Folder) -> Bool {
    guard let files = try? folder.files() else { return false }
    if files.contains(where: {$0.name.lowercased() == "package.swift"}) {
      return true
    }
    return false
  }
  
}

extension SPMBuildSystem : ConsoleSupport {}

class SPMLauncher: Launcher {
  
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
   guard let project = workbench.project, let package = findPackage(project: project) else { 
      handler?(.failed(workbench), nil)
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
      handler?(.finished(workbench), process)
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
    handler?(.running(workbench), programProc)
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
