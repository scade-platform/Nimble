//
//  SPMBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 12/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore
import SKLocalServer

class SPMBuildSystem: BuildSystem {
  
  var name: String {
    return "Swift Package"
  }
  
  func targets(in workbench: Workbench) -> [Target] {
    guard let folders = workbench.project?.folders else { return [] }
    let targets = folders.filter{canHandle(folder: $0)}.map{SPMTarget(folder: $0, workbench: workbench)}
    targets.forEach{ $0.variants.append(MacVariant(target: $0, buildSystem: self))}
    return targets
  }
  
  func run(_ variant: Variant) {
    guard let workbench = variant.target?.workbench else { return }
    do {
      try workbench.publish(tasks: [try variant.build(), try variant.run()])
    } catch {
      print(error)
    }
  }
  
  func build(_ variant: Variant) {
    //TODO: add logic
  }
  
  func clean(_ variant: Variant) {
    //TODO: add clean logic
  }
}

//MARK: - API level - private
private extension SPMBuildSystem {
  func canHandle(folder: Folder) -> Bool {
    guard let files = try? folder.files() else { return false }
    if files.contains(where: {$0.name.lowercased() == "package.swift"}) {
      return true
    }
    return false
  }
}

fileprivate class SPMTarget: Target {
  var name: String {
    folder.name
  }
  
  let folder: Folder
  var variants: [Variant] = []
  weak var workbench: Workbench?
  
  init(folder: Folder, workbench: Workbench) {
    self.folder = folder
    self.workbench = workbench
  }
}

fileprivate class MacVariant: Variant {
  var target: Target? {
    spmTarget
  }
  
  weak var spmTarget : SPMTarget?
  
  var name: String {
    "mac"
  }
  
  weak var buildSystem : BuildSystem?
  
  init(target: SPMTarget, buildSystem: SPMBuildSystem) {
    self.spmTarget = target
    self.buildSystem = buildSystem
  }
  
  func createProcess(source: Folder) -> Process {
    let proc = Process()
    proc.currentDirectoryURL = source.url
    proc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
    
    let toolchain = SKLocalServer.swiftToolchain
    if !toolchain.isEmpty {
      proc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
    } else {
      proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    }
    return proc
  }
}


// MARK: - MacVariant - Run task
extension MacVariant {
  func run() throws -> WorkbenchTask {
    guard let target = spmTarget else {
      throw VariantError.targetRequired
    }

    let process = createRunProcess(source: target.folder)
    let task = ConsoleOutputWorkbenchProcess(process, title: "Run: \(target.name) - \(self.name)", target: target)
    
    return task
  }
  
  func createRunProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["run", "--skip-build"]
    return proc
  }
}


//MARK: - MacVariant - Build task
extension MacVariant {
  func build() throws -> WorkbenchTask {
    guard let target = spmTarget else {
      throw VariantError.targetRequired
    }
    
    target.workbench?.currentDocument?.save(nil)
    
    let process = createBuildProcess(source: target.folder)
    
    let task = ConsoleOutputWorkbenchProcess(process, title: "Build: \(target.name) - \(self.name)", target: target) { [weak self] console in
      guard let self = self else { return }
      console.writeLine(string: "Finished building \(target.name) - \(self.name)")
    }
    task.console?.writeLine(string: "Building: \(target.name) - \(self.name)")
    
    return task
  }
  
  func createBuildProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics"]
    return proc
  }
}

class ConsoleTaskObserver: WorkbenchTaskObserver {
  let console: Console
  let startMessage: String?
  let endMessage: String?
  
  init(_ console: Console, startMessage: String? = nil, endMessage: String? = nil) {
    self.console = console
    self.startMessage = startMessage
    self.endMessage = endMessage
  }
  
  func taskDidStart(_ task: WorkbenchTask) {
    guard console.isReadingFromBuffer, let startMessage = startMessage else {
      return
    }
    console.writeLine(string: startMessage)
  }
  
  func taskDidFinish(_ task: WorkbenchTask) {
    defer {
      console.stopReadingFromBuffer()
    }
    guard console.isReadingFromBuffer, let endMessage = endMessage else {
      return
    }
    console.writeLine(string: endMessage)
  }
}

class ConsoleOutputWorkbenchProcess: BuildSystemTask {
  let process: Process
  var console: Console?
  
  init(_ process: Process, title: String, target: Target, handler: ((Console) -> Void)? = nil) {
    self.process = process
    super.init(process)
    self.console = openConsole(for: process, consoleTitle: title, target: target)
    let superTerminateHandler = process.terminationHandler
    process.terminationHandler = {[weak self] process in
      guard let self = self else { return }
      superTerminateHandler?(process)
      if let console = self.console {
          handler?(console)
      }
      self.console?.stopReadingFromBuffer()
    }
  }
  
  private func openConsole(for process: Process, consoleTitle title: String, target: Target) -> Console? {
     guard let workbench = target.workbench, let console = openConsole(key: target.id, title: title, in: workbench),
       !console.isReadingFromBuffer
       else {
         //The console is using by another process with the same representedObject
         return nil
     }
     
     process.standardOutput = console.output
     process.standardError = console.output
     console.startReadingFromBuffer()
     
     return console
   }
}

extension ConsoleOutputWorkbenchProcess: ConsoleSupport {}
