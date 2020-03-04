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
    guard let fileURL = workbench.currentDocument?.fileURL, let file = fileURL.file, let package = findPackage(by: file.path, in: workbench) else { return  }
    
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
    handler?(.running, spmProc)
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL, let file = fileURL.file, let package = findPackage(by: file.path, in: workbench) else { return  }
       
    
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
  
}

extension SPMBuildSystem : ConsoleSupport {}

extension SPMBuildSystem : AutoBuildable {
  
  func canBuild(file url: URL, in workbench: Workbench?) -> Bool {
    guard url.isFileURL, let file = url.file, let workbench = workbench else {
      return false
    }
    return findPackage(by: file.path, in: workbench) != nil
  }
  
  func isDefault(for file: URL, in workbench: Workbench?) -> Bool {
    return canBuild(file: file, in: workbench)
  }

}

class SPMLauncher: Launcher {
  
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL, let file = fileURL.file, let package = findPackage(by: file.path, in: workbench) else { 
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


fileprivate func findPackage(by file: Path, in workbench: Workbench) -> File? {
  //get parent directory for current file
  let parent = file.parent
  
  //looking for "pakage.swift"
  for entry in (try? parent.ls()) ?? [] {
    if entry.path.basename().lowercased() == "package.swift" {
      //if file was found return it
      return File(path: entry.path)
    }
  }
  
  //if the parent is one of the root folders then stop search
  if workbench.project?.folders.contains(where: {$0.path == parent}) ?? true {
    return nil
  }
  
  //else try to find "pakage.swift" on one level up
  return findPackage(by: parent, in: workbench)
}
