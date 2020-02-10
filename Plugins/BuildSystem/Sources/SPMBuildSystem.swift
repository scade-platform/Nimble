//
//  SPMBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 12/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

class SPMBuildSystem: BuildSystem {
  var name: String {
    return "Swift Package"
  }
  
  lazy var launcher: Launcher? = {
    return SPMLauncher(builder: self)
  }()
  
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?) {
    workbench.currentDocument?.save(nil)
    guard let curProject = workbench.project, let package = findPackage(project: curProject) else { return  }
    let fileURL = package.url
    let spmProc = Process()
    spmProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    spmProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    spmProc.arguments = ["build"]
    var spmProcConsole : Console?
    spmProc.terminationHandler = { process in
      spmProcConsole?.stopReadingFromBuffer()
      if let contents = spmProcConsole?.contents {        
        if contents.isEmpty {
          DispatchQueue.main.async {
            spmProcConsole?.close()
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
      spmProcConsole = self.openConsole(key: fileURL, title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
      spmProc.standardOutput = spmProcConsole?.output
      try? spmProc.run()
    }
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
      self.updateAndRemoveStatus(currentStatus: "Cleaning", newStatus: "Clean done", newColor: .systemGreen, workbench: workbench)
      handler?()
    }
    DispatchQueue.main.async {
      self.addStatus(status: "Cleaning", color: .systemRed, workbench: workbench)
      try? proc.run()
    }
  }
}

extension SPMBuildSystem : ConsoleSupport {}
extension SPMBuildSystem : StatusBarSupport {}

class SPMLauncher: Launcher {
  let builder: BuildSystem
  
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
      guard let curProject = workbench.project, let package = findPackage(project: curProject) else {
        self.addAndRemoveStatus(status: "Run failed", color: .systemRed, workbench: workbench)
        handler?(.failed, nil)
        return
      }
      let packageUrl = package.url
      //get package name from package describtion
      let proc = Process()
      proc.currentDirectoryURL = packageUrl.deletingLastPathComponent()
      proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
      proc.arguments = ["package", "describe"]
      let out = Pipe()
      var buffer : String? = nil
      out.fileHandleForReading.readabilityHandler = {fh in
        let data = fh.availableData
        if let str = String(data: data, encoding: .utf8), str.hasPrefix("Name: ") {
          buffer = str
          proc.terminate()
        }
        proc.terminate()
      }
      
      proc.standardOutput = out
      proc.terminationHandler = { process in
        out.fileHandleForReading.readabilityHandler = nil
        guard let describtion = buffer, let endOfFirstLine = describtion.firstIndex(of: "\n") else {
          self.updateAndRemoveStatus(currentStatus: "Starting", newStatus: "Run failed", workbench: workbench)
          handler?(.failed, nil)
          return
        }
        let prefix = describtion.prefix(through: describtion.index(endOfFirstLine, offsetBy: -1))
        let name = prefix.suffix(from: prefix.index(prefix.startIndex, offsetBy: "Name: ".count))
        
        let programProc = Process()
        programProc.currentDirectoryURL = packageUrl.deletingLastPathComponent()
        programProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        programProc.arguments = ["run", "\(name)"]
        var programProcConsole: Console?
        programProc.terminationHandler = { process in
          programProcConsole?.stopReadingFromBuffer()
          handler?(.finished, process)
        }
        DispatchQueue.main.async {
          workbench.debugArea?.isHidden = false
          programProcConsole =  self.openConsole(key: package, title: "Run: \(name)", in: workbench)
          programProc.standardOutput = programProcConsole?.output
          programProc.standardError = programProcConsole?.output
          try? programProc.run()
          self.updateAndRemoveStatus(currentStatus: "Starting", newStatus: "Running", workbench: workbench)
          handler?(.running, programProc)
        }
      }
      self.addStatus(status: "Starting", color: .systemRed, workbench: workbench)
      try? proc.run()
    }
  }
}

extension SPMLauncher : ConsoleSupport {}
extension SPMLauncher : StatusBarSupport {}

fileprivate func findPackage(project: Project) -> File? {
  for folder in project.folders {
    guard let files = try? folder.files() else { continue }
    if let package = files.first(where: {file in file.name.lowercased() == "package.swift"}) {
      return package
    }
  }
  return nil
}
