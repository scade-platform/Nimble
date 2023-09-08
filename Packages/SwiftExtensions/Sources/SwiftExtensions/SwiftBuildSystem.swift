//
//  SwiftBuildSystem.swift
//  BuildSystem
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

import NimbleCore
import BuildSystem


public class SwiftSingleFileBuildSystem: BuildSystem {

  public var name: String {
    return "Swift File"
  }

  public init() {
  }
  
  public func collectTargets(workbench: Workbench) -> TargetGroup {
    let group = TargetGroup(buildSystem: self, name: "Swift")

    guard let document = workbench.currentDocument, canHandle(document: document) else { return group }
    
    //Workaround to prevent allow compile single swift file in SPM package
    if BuildSystemsManager.shared.activeBuildSystem is Automatic {
      let spmTargets =  BuildSystemsManager.shared.allTargets(workbench: workbench).compactMap{$0 as? SPMTarget}
      let spmProjects = spmTargets.map{$0.project}
      for proj in spmProjects {
        if proj.containsSourceFile(document: document) {
          return group
        }
      }
    }
    
    let target = SwiftSingleFileTarget(workbench: workbench, buildSystem: self, document: document)
    target.variants.add(item: SwiftSingleFileMacVariant(target: target))
    group.add(item: target)
    return group
  }
  
  func canHandle(document: Document) -> Bool {
    guard let fileExtension = document.path?.extension else { return false }
    guard !fileExtension.isEmpty, fileExtension == "swift" else {
      return false
    }
    return true
  }
  
}

fileprivate class SwiftSingleFileTarget: Target {
  var document: Document

  init(workbench: Workbench, buildSystem: SwiftSingleFileBuildSystem, document: Document) {
    self.document = document

    super.init(workbench: workbench, buildSystem: buildSystem, name: document.title)
    self.icon = IconsManager.shared.icon(for: document.fileURL?.file)
  }
  
  override public func contains(file: File) -> Bool {
    if document.fileURL == file.url {
      return true
    }
    return false
  }

  /// Corresponds to the working directory
  override public func contains(folder: Folder) -> Bool {
    return document.fileURL?.deletingLastPathComponent() == folder.url
  }
}


fileprivate class SwiftSingleFileMacVariant: Variant {
  public init(target: SwiftSingleFileTarget) {
    let id = "Swift - \(target.name) - Mac"
    super.init(target: target, id: id, name: "Mac")
    self.icon = BuildSystemIcons.mac
  }

  // Returns single file target for this variant
  public override var target: SwiftSingleFileTarget {
    return super.target as! SwiftSingleFileTarget
  }

  lazy var sdkPath: String? = {
    guard let xcodeDeveloperDir = Xcode.share.developerDirectory else  {
      return nil
    }
    let sdkDirPath = xcodeDeveloperDir/"Platforms/MacOSX.platform/Developer/SDKs/"
    let macSdkDirPath = sdkDirPath/"MacOSX.sdk"
    guard macSdkDirPath.exists, macSdkDirPath.isDirectory else {
      return nil
    }
    return macSdkDirPath.string
  }()

  public override func build(output: Console) -> BuildSystemTask {
    fatalError("Not Yet Implemented")
  }
  
  func createBuildProcess(document: Document) throws -> Process {
    let documentURL = target.document.fileURL!

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

  public override func clean(output: Console) -> BuildSystemTask {
    return SwiftCleanTask(target)
  }
  
  class SwiftCleanTask: BuildSystemTask {
    var observers = ObserverSet<WorkbenchTaskObserver>()
    var isRunning: Bool = true
    let target: SwiftSingleFileTarget
    
    func stop() {
      //do nothing
    }
    
    func run() throws {
      let documentURL = target.document.fileURL!
      
      let console = ConsoleUtils.openConsole(key: "\(target.name) - Swift File", title: "\(target.name) - Swift File", in: target.workbench)
      
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
      self.observers.notify{$0.taskDidFinish(self, result: true)}
    }
    
    init(_ target: SwiftSingleFileTarget) {
      self.target = target
    }

    public var result: Bool {
      return true
    }
  }

  override func run(output: Console) -> BuildSystemTask {
    fatalError("Not Yet Implemented")
  }
  
  func createRunProcess(document: Document) throws -> Process {
    let documentURL = document.fileURL!
    let proc = Process()
    proc.currentDirectoryURL = documentURL.deletingLastPathComponent()
    proc.executableURL = URL(fileURLWithPath: "\(documentURL.deletingPathExtension())")
    return proc
  }
}
