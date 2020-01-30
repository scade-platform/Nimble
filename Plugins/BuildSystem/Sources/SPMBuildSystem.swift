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
    return SPMLauncher(builder: self)
  }()
  
  func run(in workbench: Workbench) -> BuildProgress {
    workbench.currentDocument?.save(nil)
    guard let curProject = workbench.project, let package = findPackage(project: curProject) else { return SPMBuildProgress(status: .failure) }
    let fileURL = package.url
    let spmProc = Process()
    spmProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    spmProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    spmProc.arguments = ["build"]
    var spmProcConsole : Console?
    var progress = SPMBuildProgress()
    spmProc.terminationHandler = { process in
      spmProcConsole?.stopReadingFromBuffer()
      if let contents = spmProcConsole?.contents {        
        if contents.isEmpty {
          DispatchQueue.main.async {
            spmProcConsole?.close()
          }
        } else {
          DispatchQueue.main.async {
            workbench.debugArea?.isHidden = false
          }
          progress.status = .failure
          return
        }
        let cell = StatusBarTextCell(title: "Build done.")
        DispatchQueue.main.async {
          var statusBar = workbench.statusBar
          statusBar.leftBar.append(cell)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
          var statusBar = workbench.statusBar
          if statusBar.leftBar.contains(where: {$0.title == cell.title}) {
            if let index = statusBar.leftBar.firstIndex(where: {$0.title == cell.title}) {
              statusBar.leftBar.remove(at: index)
            }
          }
        }
        progress.status = .finished
      }
    }
    DispatchQueue.main.async {
      spmProcConsole = self.openConsole(key: fileURL, title: "Compile: \(fileURL.deletingPathExtension().lastPathComponent)", in: workbench)
      spmProc.standardOutput = spmProcConsole?.output
      try? spmProc.run()
    }
    return progress
  }
}

extension SPMBuildSystem : ConsoleSupport {}

class SPMBuildProgress : MutableBuildProgressImpl {
}

class SPMLauncher: Launcher {
  let builder: BuildSystem
  
  init(builder: BuildSystem) {
    self.builder = builder
  }
  
  func launch(in workbench: Workbench) -> Process? {
    var buildProgress = builder.run(in: workbench)
    switch buildProgress.status {
    case .running:
      var process: Process?
      buildProgress.subscribe(handler: {[weak self] status in
        if status == .finished {
          process = self?.run(in: workbench)
        }
      })
      return process
    case .finished:
      return self.run(in: workbench)
    case .failure:
      return nil
    }
  }
  
  private func run(in workbench: Workbench) -> Process? {
    var programProc: Process? = Process()
    DispatchQueue.main.async {
      guard let curProject = workbench.project, let package = findPackage(project: curProject) else {
        programProc = nil
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
        guard let describtion = buffer, let endOfFirstLine = describtion.firstIndex(of: "\n") else { return }
        let prefix = describtion.prefix(through: describtion.index(endOfFirstLine, offsetBy: -1))
        let name = prefix.suffix(from: prefix.index(prefix.startIndex, offsetBy: "Name: ".count))
        
        
        programProc?.currentDirectoryURL = packageUrl.deletingLastPathComponent()
        programProc?.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        programProc?.arguments = ["run", "\(name)"]
        var programProcConsole: Console?
        programProc?.terminationHandler = { process in
          programProcConsole?.stopReadingFromBuffer()
        }
        DispatchQueue.main.async {
          workbench.debugArea?.isHidden = false
          programProcConsole =  self.openConsole(key: package, title: "Run: \(name)", in: workbench)
          programProc?.standardOutput = programProcConsole?.output
          programProc?.standardError = programProcConsole?.output
          try? programProc?.run()
        }
      }
      try? proc.run()
    }
    return programProc
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
