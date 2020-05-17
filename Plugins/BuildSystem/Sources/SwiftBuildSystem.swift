//
//  SwiftBuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 10/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation

import NimbleCore
import BuildSystem
import SKLocalServer

class SwiftBuildSystem: BuildSystem {
  
  var name: String {
    return "Swift File"
  }
  
  func targets(in workbench: Workbench) -> [Target] {
    guard let document = workbench.currentDocument, canHandle(document: document) else { return [] }
    
    //Workaround to prevent allow compile single swift file in SPM package
    if BuildSystemsManager.shared.activeBuildSystem is Automatic {
      if let spmBuildSystem = BuildSystemsManager.shared.buildSystems.first(where: {$0 is SPMBuildSystem}) {
        let spmTargets = spmBuildSystem.targets(in: workbench).compactMap{$0 as? SPMTarget}
        guard !spmTargets.isEmpty else { return [] }
        if spmTargets.containsSwiftFile(document: document) {
          return []
        }
      }
    }
    
    let target = SwiftTarget(document: document, workbench: workbench)
    target.variants.append(SingleDocumentVariant(target: target, buildSystem: self))
    return [target]
  }
  
  func run(_ variant: Variant) {
    guard let workbench = variant.target?.workbench else { return }
    do {
      let buildTask = try variant.build()
      workbench.publish(task: buildTask) { task in
        guard let workbenchProcess = task as? BuildSystemTask,
          let console = workbenchProcess.console else {
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
  
  func canHandle(document: Document) -> Bool {
    guard let fileExtension = document.path?.extension else { return false }
    guard !fileExtension.isEmpty, fileExtension == "swift" else {
      return false
    }
    return true
  }
  
}

fileprivate class SwiftTarget: Target {
  var name: String {
    document.title
  }
  
  let document: Document
  var variants: [Variant] = []
  weak var workbench: Workbench?
  
  init(document: Document, workbench: Workbench) {
    self.document = document
    self.workbench = workbench
  }
}

fileprivate class SingleDocumentVariant: Variant {
  var target: Target? {
    swiftTarget
  }
  
  weak var swiftTarget : SwiftTarget?
  
  var name: String {
    "Single Swift File"
  }
  
  weak var buildSystem : BuildSystem?
  
  lazy var sdkPath: String? = {
    guard let sdkFolder = Folder(path: "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/") else {
      return nil
    }
    for folder in (try? sdkFolder.subfolders()) ?? [] {
      if folder.name.starts(with: "MacOSX10"), folder.name.hasSuffix(".sdk") {
        return folder.path.string
      }
    }
    return nil
  }()
  
  init(target: SwiftTarget, buildSystem: SwiftBuildSystem) {
    self.swiftTarget = target
    self.buildSystem = buildSystem
  }
}

extension SingleDocumentVariant {
  enum SwiftFileError: Error {
    case URLRequired(Document)
  }
}

//MARK: - SingleDocumentVariant - Build task
extension SingleDocumentVariant {
  func build() throws -> WorkbenchTask {
    guard let target = swiftTarget else {
      throw VariantError.targetRequired
    }
    
    target.workbench?.currentDocument?.save(nil)
    
    let process = try createBuildProcess(document: target.document)
    
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
  
  func createBuildProcess(document: Document) throws -> Process {
    guard let documentURL = document.fileURL else {
      throw SwiftFileError.URLRequired(document)
    }
    
    let proc = Process()
    proc.currentDirectoryURL = documentURL.deletingLastPathComponent()
    
    let toolchain = SKLocalServer.swiftToolchain
    if !toolchain.isEmpty, let sdkPath = sdkPath {
      proc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swiftc")
      proc.arguments = [documentURL.path, "-sdk", "\(sdkPath)", "-Xfrontend", "-color-diagnostics"]
    } else {
      proc.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
      proc.arguments = [documentURL.path, "-Xfrontend", "-color-diagnostics"]
    }
    return proc
  }
}

//MARK: - SingleDocumentVariant - Clean task
extension SingleDocumentVariant {
  func clean() throws -> WorkbenchTask {
    guard let target = swiftTarget else {
      throw VariantError.targetRequired
    }
    
    return SwiftCleanTask(target)
  }
  
  class SwiftCleanTask: WorkbenchTask {
    var observers = ObserverSet<WorkbenchTaskObserver>()
    var isRunning: Bool = true
    let target: SwiftTarget
    
    func stop() {
      //do nothing
    }
    
    func run() throws {
      guard let workbench = target.workbench else {
        isRunning = false
        return
      }
      
      guard let documentURL = target.document.fileURL else {
        isRunning = false
        return
      }
      
      let console = ConsoleUtils.openConsole(key: target.id , title: "Clean: \(documentURL.lastPathComponent)", in: workbench)
      
      guard let file = File(url: documentURL.deletingPathExtension()), file.exists else {
        console?.startReadingFromBuffer()
        console?.writeLine(string: "File not found: \(documentURL.deletingPathExtension().path)")
        console?.stopReadingFromBuffer()
        isRunning = false
        return
      }
      
      try file.path.delete()
      console?.startReadingFromBuffer()
      console?.writeLine(string: "File deleted: \(documentURL.deletingPathExtension().path)")
      console?.stopReadingFromBuffer()
      isRunning = false
      self.observers.notify{$0.taskDidFinish(self)}
    }
    
    init(_ target: SwiftTarget) {
      self.target = target
    }
  }
}

//MARK: - SingleDocumentVariant - Clean task
extension SingleDocumentVariant {
  func run() throws -> WorkbenchTask {
    guard let target = swiftTarget else {
      throw VariantError.targetRequired
    }

    let process = try createRunProcess(document: target.document)
    let task = BuildSystemTask(process)
    
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: target.id, title: "Run: \(target.name) - \(self.name)", in: workbench) {
      task.output(to: console)
    }
    
    return task
  }
  
  func createRunProcess(document: Document) throws -> Process {
    guard let documentURL = document.fileURL else {
      throw SwiftFileError.URLRequired(document)
    }
    
    let proc = Process()
    proc.currentDirectoryURL = documentURL.deletingLastPathComponent()
    proc.executableURL = URL(fileURLWithPath: "\(documentURL.deletingPathExtension())")
    return proc
  }
}
