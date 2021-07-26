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
import SwiftExtensions


class SwiftBuildSystem: BuildSystem {
  var name: String {
    return "Swift File"
  }
  
  func collectTargets(from workbench: Workbench) -> [Target] {
    guard let document = workbench.currentDocument, canHandle(document: document) else { return [] }
    
    //Workaround to prevent allow compile single swift file in SPM package
    if BuildSystemsManager.shared.activeBuildSystem is Automatic {
      if let spmBuildSystem = BuildSystemsManager.shared.buildSystems.first(where: {$0 is SPMBuildSystem}) {
        let spmTargets = spmBuildSystem.targets(in: workbench).compactMap{$0 as? SPMTarget}
        if  !spmTargets.isEmpty, spmTargets.containsSwiftFile(document: document) {
          return []
        }
      }
    }
    
    let target = SwiftTarget(document: document, workbench: workbench, buildSystem: self)
    target.variants.append(SingleDocumentVariant(target: target))
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
  
  lazy var icon: Icon? = {
    IconsManager.shared.icon(for: document.fileURL?.file)
  }()

  var variants: [Variant] = []

  var buildSystem: BuildSystem { swiftBuildSystem }

  let document: Document

  weak var workbench: Workbench?
  weak var swiftBuildSystem: SwiftBuildSystem!

  init(document: Document, workbench: Workbench, buildSystem: SwiftBuildSystem) {
    self.document = document
    self.workbench = workbench
    self.swiftBuildSystem = buildSystem
  }
  
  func contains(file: File) -> Bool {
    if document.fileURL == file.url {
      return true
    }
    return false
  }

  /// Corresponds to the working directory
  func contains(folder: Folder) -> Bool {
    return document.fileURL?.deletingLastPathComponent() == folder.url
  }
}


fileprivate class SingleDocumentVariant: Variant {
  var target: Target? {
    swiftTarget
  }
  
  weak var swiftTarget : SwiftTarget!
  
  var icon: Icon? {
    BuildSystemIcons.mac
  }
  
  var name: String {
    "Mac"
  }

  lazy var sdkPath: String? = {
    guard let xcodeDeveloperDir = Xcode.developerDirectory else  {
      return nil
    }
    let sdkDirPath = xcodeDeveloperDir/"Platforms/MacOSX.platform/Developer/SDKs/"
    let macSdkDirPath = sdkDirPath/"MacOSX.sdk"
    guard macSdkDirPath.exists, macSdkDirPath.isDirectory else {
      return nil
    }
    return macSdkDirPath.string
  }()
  
  init(target: SwiftTarget) {
    self.swiftTarget = target
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
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: "\(target.name) - Swift File", title: "\(target.name) - Swift File", in: workbench) {
      let taskConsole = task.output(to: console) {  [weak self] console in
        guard let self = self else { return }
        console.writeLine(string: "Finished Building \(target.name) - \(self.name)")
        console.stopReadingFromBuffer()
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
    
    let toolchain = SwiftExtensions.Settings.shared.swiftToolchain
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
      
      let console = ConsoleUtils.openConsole(key: "\(target.name) - Swift File", title: "\(target.name) - Swift File", in: workbench)
      
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
    
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: "\(target.name) - Swift File", title: "\(target.name) - Swift File", in: workbench) {
      task.output(to: console) {console in
        console.stopReadingFromBuffer()
      }
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
