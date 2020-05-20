//
//  SPMBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 12/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation

import NimbleCore
import BuildSystem
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
      let buildTask = try variant.build()
      workbench.publish(task: buildTask) { task in
        guard let consoleOutputTask = task as? BuildSystemTask,
          let console = consoleOutputTask.console else {
            return
        }
        
        DispatchQueue.main.async {
          //show console with build result
          ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
        }
        
        //If build without error
        if !console.contents.lowercased().contains("error:") {
          if let runTask = try? variant.run() {
            
            workbench.publish(task: runTask) { _ in
              DispatchQueue.main.async {
                //show console with run result
                ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
              }
            }
            
            //then run
            try? runTask.run()
          }
        }
      }
      try buildTask.run()
    } catch {
      print(error)
    }
  }
  
  func build(_ variant: Variant) {
    guard let workbench = variant.target?.workbench else { return }
    do {
      let buildTask = try variant.build()
      workbench.publish(task: buildTask) { _ in
        DispatchQueue.main.async {
          //show console with result
          ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
        }
      }
      try buildTask.run()
    } catch {
      print(error)
    }
  }
  
  func clean(_ variant: Variant) {
    guard let workbench = variant.target?.workbench else { return }
    do {
      let cleanTask = try variant.clean()
      workbench.publish(task: cleanTask) { _ in
        DispatchQueue.main.async {
          //show console with result
          ConsoleUtils.showConsoleTillFirstEscPress(in: workbench)
        }
      }
      try cleanTask.run()
    } catch {
      print(error)
    }
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

class SPMTarget: Target {
  var name: String {
    folder.name
  }
  
  lazy var icon: Icon? = {
    guard let files = try? folder.files() else { return nil }
    //There is at least package.swift file
    if let swiftFile = files.first(where: {$0.extension == "swift"}) {
      return IconsManager.shared.icon(for: swiftFile)
    }
    return nil
  }()
  
  let folder: Folder
  var variants: [Variant] = []
  weak var workbench: Workbench?
  
  init(folder: Folder, workbench: Workbench) {
    self.folder = folder
    self.workbench = workbench
  }
  
  func contain(file: File) -> Bool {
    let filePathString = file.path.string
    if folder.path.string.count < filePathString.count, filePathString.hasPrefix(folder.path.string){
      return true
    }
    return false
  }
}

fileprivate class MacVariant: Variant {
  var target: Target? {
    spmTarget
  }
  
  var icon: Icon? {
    BuildSystemIcons.mac
  }
  
  weak var spmTarget : SPMTarget?
  
  var name: String {
    "Mac"
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
    let task = BuildSystemTask(process)
    
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: target.id, title: "Run: \(target.name) - \(self.name)", in: workbench) {
      task.output(to: console)
    }
    
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
    
    let task = BuildSystemTask(process)
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: target.id, title: "Build: \(target.name) - \(self.name)", in: workbench) {
      let taskConsole = task.output(to: console) {  [weak self] console in
        guard let self = self else { return }
        console.writeLine(string: "Finished Building \(target.name) - \(self.name)")
      }
      taskConsole?.writeLine(string: "Building: \(target.name) - \(self.name)")
    }
    
    return task
  }
  
  func createBuildProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics"]
    return proc
  }
}

//MARK: - MacVariant - Clean task
extension MacVariant {
  func clean() throws -> WorkbenchTask {
    guard let target = spmTarget else {
      throw VariantError.targetRequired
    }
    
    let process = createCleanProcess(source: target.folder)
    let task = BuildSystemTask(process)
    
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: target.id, title: "Clean: \(target.name) - \(self.name)", in: workbench) {
      let taskConsole = task.output(to: console) {[weak self] console in
        guard let self = self else { return }
        console.writeLine(string: "Finished Cleaning \(target.name) - \(self.name)")
      }
      taskConsole?.writeLine(string: "Cleaning: \(target.name) - \(self.name)")
    }
    return task
  }
  
  func createCleanProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["package", "clean"]
    return proc
  }
}


extension Array where Element == SPMTarget {
  func containsSwiftFile(document: Document) -> Bool {
    guard let file = document.fileURL?.file else { return false }
    for target in self {
      if target.contain(file: file) {
        return true
      }      
    }
    return false
  }
}
