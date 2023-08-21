//
//  SPMBuildSystem.swift
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


public class SPMBuildSystem: BuildSystem {  
  public var name: String {
    return "Swift Package"
  }

  public init() {
  }

  private func makeAndroidVariants(target: SPMTarget) -> [Variant] {
    return AndroidBuildTarget.allCases.compactMap {
      guard let toolchain = makeAndroidSwiftToolchain(for: $0) else { return nil }
      return UserDefinedToolchainVariant(target: target, toolchain: toolchain)
    }
  }
  
  public func collectTargets(from workbench: Workbench) -> [Target] {
    guard let folders = workbench.project?.folders else { return [] }

    let targets = folders.filter{ canHandle(folder: $0) }.map{
      SPMTarget(folder: $0, workbench: workbench, buildSystem: self)
    }

//    targets.forEach{
//      // creating default Mac variant
//      $0.variants.append(MacVariant(target: $0))
//
//      // creating variants for all android platforms
//      $0.variants += makeAndroidVariants(target: $0)
//
//      // creating variants for all user defined platforms
//      for toolchain in SwiftExtensions.Settings.shared.platforms {
//        $0.variants.append(UserDefinedToolchainVariant(target: $0, toolchain: toolchain))
//      }
//    }
    return targets
  }
  
  public func run(_ variant: Variant) {
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
  
  public func build(_ variant: Variant) {
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
  
  public func clean(_ variant: Variant) {
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
    if files.contains(where: { $0.name.lowercased() == "package.swift" }) {
      return true
    }
    return false
  }
}

class SPMTarget: Target {
  enum VariantsGroups: String, CaseIterable {
    case allProducts = "All Products"
    case packages = "Packages"
    case targets = "Targets"
  }

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

  lazy var variants: [Variant] = {
    buildModel.createVariants(for: self)
  }()

  private var buildModel: BuildSystemModel {
    modelFactory.createBuildSystemModel()
  }

  lazy var variantsGroups: [String] = VariantsGroups.allCases.map { $0.rawValue }

  var buildSystem: BuildSystem { spmBuildSystem }

  let folder: Folder

  weak var workbench: Workbench?

  weak var spmBuildSystem: SPMBuildSystem!

  private let modelFactory: SPMTargetModelFactory

  init(folder: Folder, workbench: Workbench, buildSystem: SPMBuildSystem) {
    self.folder = folder
    self.workbench = workbench
    self.spmBuildSystem = buildSystem
    self.modelFactory = SPMTargetModelFactory(folder: folder.url)
  }

  func contains(folder: Folder) -> Bool {
    return self.folder == folder
  }

  func group(for variant: Variant) -> UInt? {
    guard let buildSystemModelVariant = variant as? BuildSystemModelVariant else {
      return nil
    }
    switch buildSystemModelVariant.buildModel {
    case is SPMPackageBuildableModel:
      return 0
    case is SPMProductBuildableModel:
      return 1
    case is SPMTargetBuildableModel:
      return 2
    default:
      return nil
    }
  }
}


class SPMVariant {
  var target: Target? {
    spmTarget
  }

  var name: String

  weak var spmTarget : SPMTarget!

  init(target: SPMTarget, name: String) {
    self.spmTarget = target
    self.name = name
  }

  func createProcess(source: Folder) -> Process {
    preconditionFailure("This method must be overridden") 
  }

  func createBuildProcess(source: Folder) -> Process {
    preconditionFailure("This method must be overridden") 
  }
}


//MARK: - SPMVariant - Build task
extension SPMVariant {
  func build() throws -> WorkbenchTask {
    guard let target = spmTarget else {
      throw VariantError.targetRequired
    }
    
    target.workbench?.currentDocument?.save(nil)
    
    let process = createBuildProcess(source: target.folder)
    
    let task = BuildSystemTask(process)
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: "\(target.name) - SPM", title: "\(target.name) - SPM", in: workbench) {
      let taskConsole = task.output(to: console) {  [weak self] console in
        guard let self = self else { return }
        console.writeLine(string: "Finished Building \(target.name) - \(self.name)")
        console.stopReadingFromBuffer()
      }
      taskConsole?.writeLine(string: "Building: \(target.name) - \(self.name)")
    }
    
    return task
  }
}


//MARK: - SPMVariant - Clean task
extension SPMVariant {
  func clean() throws -> WorkbenchTask {
    guard let target = spmTarget else {
      throw VariantError.targetRequired
    }
    
    let process = createCleanProcess(source: target.folder)
    let task = BuildSystemTask(process)
    
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: "\(target.name) - SPM", title: "\(target.name) - SPM", in: workbench) {
      let taskConsole = task.output(to: console) {[weak self] console in
        guard let self = self else { return }
        console.writeLine(string: "Finished Cleaning \(target.name) - \(self.name)")
        console.stopReadingFromBuffer()
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


fileprivate class MacVariant: SPMVariant, SwiftVariant {
  var toolchain: SwiftToolchain? { return nil }

  var icon: Icon? {
    BuildSystemIcons.mac
  }

  init(target: SPMTarget) {
    super.init(target: target, name: "Mac")
  }
  
  override func createProcess(source: Folder) -> Process {
    let proc = Process()
    proc.currentDirectoryURL = source.url
    proc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
    
    let toolchain = SwiftExtensions.Settings.shared.swiftToolchain
    if !toolchain.isEmpty {
      proc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
      if !FileManager.default.fileExists(atPath: proc.executableURL!.path) {
        proc.executableURL = URL(fileURLWithPath: "\(toolchain)/bin/swift")
      }
    } else {
      proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    }
    return proc
  }

  override func createBuildProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics",
                      "--disable-build-manifest-caching"]
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
    
    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: "\(target.name) - SPM", title: "\(target.name) - SPM", in: workbench) {
      task.output(to: console) { console in
        console.stopReadingFromBuffer()
      }
    }
    
    return task
  }
  
  func createRunProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["run", "--skip-build"]
    return proc
  }
}


fileprivate class UserDefinedToolchainVariant: SPMVariant, SwiftVariant {
  var toolchain: SwiftToolchain? { return _toolchain }

  var icon: Icon? = nil

  private var _toolchain: SwiftToolchain

  init(target: SPMTarget, toolchain: SwiftToolchain) {
    self._toolchain = toolchain
    super.init(target: target, name: toolchain.name)
  }
  
  override func createProcess(source: Folder) -> Process {
    let proc = Process()
    proc.currentDirectoryURL = source.url
    proc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
    proc.executableURL = URL(fileURLWithPath: _toolchain.compiler + "/bin/swift")
    return proc
  }

  override func createBuildProcess(source: Folder) -> Process {
    var dict: [String : Any] = [:]
    dict["version"] = 1
    dict["target"] = _toolchain.target
    dict["sdk"] = _toolchain.sdkRoot
    dict["toolchain-bin-dir"] = _toolchain.compiler + "/bin"
    dict["extra-swiftc-flags"] = _toolchain.compilerFlags
    dict["extra-cc-flags"] = Array<String>()
    dict["extra-cpp-flags"] = Array<String>()
    
    let buildPath = source.path.join(".build")
    let descPath = buildPath.join("desc-" + _toolchain.name + ".json")
    
    do {
      if !FileManager.default.fileExists(atPath: buildPath.string) {
        try FileManager.default.createDirectory(atPath: buildPath.string,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
      }
      let descData = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
      try descData.write(to: descPath, atomically: true)
    }
    catch {
      print("ERROR: can't write SPM description file to \(descPath): \(error)")
    }

    let proc = createProcess(source: source)
    proc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics",
                      "--disable-build-manifest-caching",
                      "--destination", descPath.string]

    // setting build process environment if set is toolchain
    print("BEFORE ENV")
    if let toolchainEnvironment = _toolchain.environment {
      print("ENV DEFINED")
      var procEnvironment = ProcessInfo.processInfo.environment
      for (key, val) in toolchainEnvironment {
        print("ENV: \(key) = \(val)")
        procEnvironment[key] = val
      }

      proc.environment = procEnvironment
    }

    return proc
  }
}

class BuildSystemModelVariant: SPMVariant, SwiftVariant {
  var toolchain: SwiftExtensions.SwiftToolchain? {
    nil
  }

  var icon: Icon? {
    BuildSystemIcons.mac
  }

  let buildModel: SwiftBuildableModel
  private let commonCompilerArgument = ["-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics"]

  init(target: SPMTarget, model: SwiftBuildableModel) {
    self.buildModel = model
    super.init(target: target, name: model.title)
  }

  override func createProcess(source: Folder) -> Process {
    let proc = Process()
    proc.currentDirectoryURL = source.url
    proc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]

    let toolchain = SwiftExtensions.Settings.shared.swiftToolchain
    if !toolchain.isEmpty {
      proc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
      if !FileManager.default.fileExists(atPath: proc.executableURL!.path) {
        proc.executableURL = URL(fileURLWithPath: "\(toolchain)/bin/swift")
      }
    } else {
      proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    }
    return proc
  }

  override func createBuildProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = buildModel.buildCommandArguments + commonCompilerArgument
    return proc
  }
}

// MARK: - MacVariant - Run task
extension BuildSystemModelVariant {
  func run() throws -> WorkbenchTask {
    guard let target = spmTarget else {
      throw VariantError.targetRequired
    }

    let process = createRunProcess(source: target.folder)
    let task = BuildSystemTask(process)

    if let workbench = target.workbench, let console = ConsoleUtils.openConsole(key: "\(target.name) - SPM", title: "\(target.name) - SPM", in: workbench) {
      task.output(to: console) { console in
        console.stopReadingFromBuffer()
      }
    }

    return task
  }

  func createRunProcess(source: Folder) -> Process {
    let proc = createProcess(source: source)
    proc.arguments = ["run", "--skip-build"]
    return proc
  }
}


extension Array where Element == SPMTarget {
  func containsSwiftFile(document: Document) -> Bool {
    guard let filePathString = document.fileURL?.file?.path.string else { return false }
    for target in self {
      let targetFolder = target.folder
      if targetFolder.path.string.count < filePathString.count, filePathString.hasPrefix(targetFolder.path.string){
        return true
      }      
    }
    return false
  }
}
