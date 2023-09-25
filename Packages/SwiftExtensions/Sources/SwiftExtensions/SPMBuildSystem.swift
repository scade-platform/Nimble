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
import AppKit

import NimbleCore
import BuildSystem


public class SPMBuildSystem: BuildSystem {
  public var name: String {
    return "Swift Package"
  }

  public init() {
  }
  
  public func collectTargets(workbench: Workbench) -> TargetGroup {
    // creating root group for all folders
    let group = TargetGroup(buildSystem: self, name: "SPM")

    guard let folders = workbench.project?.folders else { return group }

    let filteredFolders = folders.filter{ canHandle(folder: $0) }
    for folder in filteredFolders {
      // parsing project manifest
      var spmProjectOpt: SPMPackageReaderPackage? = nil
      do {
        let spmReader = SPMPackageReader(path: folder.path)
        spmProjectOpt = try spmReader.read()
      }
      catch {
        let errMsg = "Can't parse Package.swift SPM Manifest for project '\(folder.path.string): " +
                     error.localizedDescription
        workbench.publish(diagnosticMessage: errMsg,
                          severity: .error,
                          source: .other("SPM Build System"))
        return group
      }

      let spmProject = spmProjectOpt!

      // creating SPMProject instance for project folder
      let project = SPMProject(workbench: workbench, folder: folder, name: spmProject.name)

      // creating group for project
      let projectGroup = TargetGroup(buildSystem: self, name: project.name)
      projectGroup.icon = IconsManager.icon(systemSymbolName: "swift")

      // creating target and variant for all products
      let allProducts = SPMAllTarget(workbench: workbench, buildSystem: self, project: project)
      projectGroup.add(item: allProducts)
      let allProductsVariant = SPMMacVariant(target: allProducts)
      allProducts.variants.add(item: allProductsVariant)

      projectGroup.addSeparator()

      // creating targets and variants for all SPM products
      for product in spmProject.products {
        let productTarget = SPMProductTarget(workbench: workbench,
                                             buildSystem: self,
                                             name: product.name,
                                             isExecutable: product.isExecutable,
                                             project: project)
        projectGroup.add(item: productTarget)

        let variant = SPMMacVariant(target: productTarget)
        productTarget.variants.add(item: variant)
      }

      projectGroup.addSeparator()

      // creating targets and variants for all SPM targets
      for target in spmProject.targets {
        let targetTarget = SPMTargetTarget(workbench: workbench,
                                           buildSystem: self,
                                           name: target.name,
                                           project: project)
        projectGroup.add(item: targetTarget)

        let variant = SPMMacVariant(target: targetTarget)
        targetTarget.variants.add(item: variant)
      }

      group.add(item: projectGroup)
    }

    return group
  }

  private func canHandle(folder: Folder) -> Bool {
    guard let files = try? folder.files() else { return false }
    if files.contains(where: { $0.name.lowercased() == "package.swift" }) {
      return true
    }
    return false
  }
}


// Represents single SPM projects for targets/variants
public class SPMProject {
  // Project workbench
  public private(set) var workbench: Workbench

  // The folder where SPM project is located 
  public private(set) var folder: Folder

  // Project name
  public private(set) var name: String

  // Initializes SPM project for specified workbench and folder
  public init(workbench: Workbench, folder: Folder, name: String) {
    self.workbench = workbench
    self.folder = folder
    self.name = name
  }

  // Returns true if SPM project contains source file
  public func containsSourceFile(document: Document) -> Bool {
    guard let filePathString = document.fileURL?.file?.path.string else { return false }

    return folder.path.string.count < filePathString.count && filePathString.hasPrefix(folder.path.string)
  }
}


// Base class for all SPM targets
public class SPMTarget: Target {
  public private(set) var project: SPMProject

  // Initializes SPM target
  public init(workbench: Workbench, buildSystem: SPMBuildSystem, name: String, project: SPMProject) {
    self.project = project
    super.init(workbench: workbench, buildSystem: buildSystem, name: name)
  }

  // Returns string containing target type and name
  public var typeAndName: String {
    fatalError("Should be implemented in derived classes")
  }
}


// Represents build target corresponding to SPM target
public class SPMTargetTarget: SPMTarget {
  // Initializes target with specified name
  public override init(workbench: Workbench, buildSystem: SPMBuildSystem, name: String, project: SPMProject) {
    super.init(workbench: workbench, buildSystem: buildSystem, name: name, project: project)
    self.icon = IconsManager.icon(systemSymbolName: "cube")
  }

  // Returns string representation of type of target
  public override var typeAndName: String {
    return "Target " + name
  }
}


// Represents build target corresponding to SPM product
public class SPMProductTarget: SPMTarget {
  public private(set) var isExecutable: Bool

  // Initializes target with specified name
  public init(workbench: Workbench,
              buildSystem: SPMBuildSystem,
              name: String,
              isExecutable: Bool,
              project: SPMProject) {
    self.isExecutable = isExecutable
    super.init(workbench: workbench, buildSystem: buildSystem, name: name, project: project)
    self.icon = IconsManager.icon(systemSymbolName: "cube.fill")
  }

  // Returns string representation of type of target
  public override var typeAndName: String {
    return "Product " + name
  }
}


// Represents build target corresponding to all products in SPM package
public class SPMAllTarget: SPMTarget {
  // Initializes all target for all products
  public init(workbench: Workbench, buildSystem: SPMBuildSystem, project: SPMProject) {
    super.init(workbench: workbench, buildSystem: buildSystem, name: "All Products", project: project)
    self.icon = IconsManager.icon(systemSymbolName: "suitcase")
    self.selectedName = "\(project.name) - \(name)"
  }

  // Returns string representation of type of target
  public override var typeAndName: String {
    return "All Products"
  }
}


// Base class for all SPM variants
open class SPMVariant: Variant {
  // Initializes variant with specified SPM target and name
  public init(target: SPMTarget, name: String) {
    let id = "SPM - \(target.project.name) - \(target.typeAndName) - \(name)"
    super.init(target: target, id: id, name: name)
  }

  // Returns reference to SPM target
  public override var target: SPMTarget {
    return super.target as! SPMTarget
  }

  public override func clean(output: Console) -> BuildSystemTask {
    let task = WorkbenchProcess(executablePath: getSwiftToolPath(),
                                currentDirectory: target.project.folder.path,
                                arguments: ["package", "clean"])
    task.redirectOutput(to: output)
    return task
  }

  // Returns path to swift tool
  func getSwiftToolPath() -> Path {
    let toolchain = SwiftExtensions.Settings.shared.swiftToolchain
    if !toolchain.isEmpty {
      var path = Path("\(toolchain)/usr/bin/swift")!
      if !FileManager.default.fileExists(atPath: path.string) {
        path = Path("\(toolchain)/bin/swift")!
      }

      return path
    } else {
      return Path("/usr/bin/swift")!
    }
  }
}


// SPM variant for MacOS
class SPMMacVariant: SPMVariant {
  // Initializes SPM variant for MacOS for specified target. Adds variant into target
  public init(target: SPMTarget) {
    super.init(target: target, name: "MacOS")
    self.icon = IconsManager.icon(systemSymbolName: "desktopcomputer")
  }

  public override func build(output: Console) -> BuildSystemTask {
    var targetArgs: [String] = []
    if target is SPMProductTarget {
      targetArgs += ["--product", target.name]
    } else if target is SPMTargetTarget {
      targetArgs += ["--target", target.name]
    }

    let buildArgs = ["build",
                     "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics",
                    "--disable-build-manifest-caching"]
                    + targetArgs
    let task = WorkbenchProcess(executablePath: getSwiftToolPath(),
                                currentDirectory: target.project.folder.path,
                                arguments: buildArgs)
    task.redirectOutput(to: output)
    return task
  }

  public override func canRun() -> Bool {
    guard let productTarget = target as? SPMProductTarget else { return false }
    return productTarget.isExecutable
  }

  public override func run(output: Console) -> BuildSystemTask {
    let task = WorkbenchProcess(executablePath: getSwiftToolPath(),
                                currentDirectory: target.project.folder.path,
                                arguments: ["run", "--skip-build", "\(target.name)"])
    task.redirectOutput(to: output)
    return task
  }
}
