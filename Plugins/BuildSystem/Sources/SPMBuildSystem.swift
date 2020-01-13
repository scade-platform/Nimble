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
  
  func run(in workbench: Workbench) -> BuildProgress {
    workbench.currentDocument?.save(nil)
    guard let curProject = workbench.project, let package = findPackage(project: curProject) else { return SPMBuildProgress() }
    let fileURL = package.url
    let spmProc = Process()
    spmProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    spmProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    spmProc.arguments = ["build"]
    var spmProcConsole : Console?
    spmProc.terminationHandler = { [weak self] process in
      spmProcConsole?.stopReadingFromBuffer()
      self?.run(package: fileURL, in: workbench)
    }
    DispatchQueue.main.async {
      workbench.debugArea?.isHidden = false
      spmProcConsole = workbench.createConsole(title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", show: true)
      spmProc.standardError = spmProcConsole?.output
      spmProc.standardOutput = spmProcConsole?.output
      try? spmProc.run()
    }
    return SPMBuildProgress()
  }
  
  private func findPackage(project: Project) -> File? {
    for folder in project.folders {
      guard let files = try? folder.files() else { continue }
      if let package = files.first(where: {file in file.name.lowercased() == "package.swift"}) {
        return package
      }
    }
    return nil
  }
  
  private func run(package: URL, in workbench: Workbench) {
    //get package name from package describtion
    let proc = Process()
    proc.currentDirectoryURL = package.deletingLastPathComponent()
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
      guard let describtion = buffer, let endOfFirstLine = describtion.firstIndex(of: "\n") else { return }
      let prefix = describtion.prefix(through: describtion.index(endOfFirstLine, offsetBy: -1))
      let name = prefix.suffix(from: prefix.index(prefix.startIndex, offsetBy: "Name: ".count))
      
      let programProc = Process()
      programProc.currentDirectoryURL = package.deletingLastPathComponent()
      programProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
      programProc.arguments = ["run", "\(name)"]
      var programProcConsole: Console?
      programProc.terminationHandler = { process in
        programProcConsole?.stopReadingFromBuffer()
      }
      DispatchQueue.main.async {
        programProcConsole = workbench.createConsole(title: "Run: \(name)", show: true)
        programProc.standardOutput = programProcConsole?.output
        programProc.standardError = programProcConsole?.output
        try? programProc.run()
      }
    }
    try? proc.run()
    
  }
  
}

struct SPMBuildProgress : BuildProgress {
  
}
