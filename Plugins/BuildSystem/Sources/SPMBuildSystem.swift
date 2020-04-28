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
  
  func targets(from workbench: Workbench) -> [Target] {
    guard let folders = workbench.project?.folders else { return [] }
    return folders.filter{ canHandle(folder: $0) }.map{ Target(name: $0.name, variants: [SPMBuildSystem.mac(source: $0)]) }
  }
  
  func run(_ variant: Variant, in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    guard let process = variant.createRunProcess?() else {
      handler?(.failed, nil)
      return
    }
    
    guard let console = openConsole(key: variant.sourceName, title: "Run: \(variant.name)", in: workbench),
      !console.isReadingFromBuffer
      else {
        //The console is using by another process with the same representedObject
        return
    }
    
    process.terminationHandler = { process in
      console.stopReadingFromBuffer()
      handler?(.finished, process)
    }
    
    process.standardOutput = console.output
    process.standardError = console.output
    console.startReadingFromBuffer()
    
    try? process.run()
    handler?(.running, process)
  }
  
  func build(_ variant: Variant, in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
    //TODO: add build logic
  }
  
  func clean(_ variant: Variant, in workbench: Workbench, handler: (() -> Void)?) {
    //TODO: add clean logic
  }
}

//API level - private
private extension SPMBuildSystem {
  func canHandle(folder: Folder) -> Bool {
    guard let files = try? folder.files() else { return false }
    if files.contains(where: {$0.name.lowercased() == "package.swift"}) {
      return true
    }
    return false
  }
}

//Mac variants
private extension SPMBuildSystem {
  static func mac(source: Folder) -> Variant {
    func createRunProcess() -> Process? {
      let proc = Process()
      proc.currentDirectoryURL = source.url
      proc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
      proc.arguments = ["run", "--skip-build"]
      
      let toolchain = SKLocalServer.swiftToolchain
      if !toolchain.isEmpty {
        proc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
      } else {
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
      }
      return proc
    }
    
    return Variant(name: "mac", icon: nil, source: source, createRunProcess: createRunProcess)
  }
}

extension SPMBuildSystem : ConsoleSupport {}




//  lazy var launcher: Launcher? = {
//    return SPMLauncher()
//  }()
//
//
//  func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
//    workbench.currentDocument?.save(nil)
//    guard let project = workbench.project, let package = findPackage(project: project) else { return  }
//
//
//    let packageURL = package.url
//
//    let spmProc = Process()
//    spmProc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
//    spmProc.currentDirectoryURL = packageURL.deletingLastPathComponent()
//
//
//    //Mock
////    let toolchain = "/Library/Developer/Toolchains/swift-5.1.4-RELEASE.xctoolchain/"
//    let toolchain = SKLocalServer.swiftToolchain
//    if !toolchain.isEmpty {
//      spmProc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
//    } else {
//      spmProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
//    }
//
//    spmProc.arguments = ["build", "-Xswiftc", "-Xfrontend", "-Xswiftc", "-color-diagnostics"]
//
//
//    var spmProcConsole : Console?
//
//    spmProc.terminationHandler = { process in
//      spmProcConsole?.writeLine(string: "Finished building \(packageURL.deletingLastPathComponent().lastPathComponent)")
//      spmProcConsole?.stopReadingFromBuffer()
//
//
//      if let contents = spmProcConsole?.contents {
//        if contents.isEmpty {
//          DispatchQueue.main.async {
//            spmProcConsole?.close()
//          }
//          handler?(.finished, process)
//        } else {
//          if contents.contains("error:"){
//            handler?(.failed, process)
//          } else {
//            handler?(.finished, process)
//          }
//        }
//      }
//    }
//
//    spmProcConsole = self.openConsole(key: packageURL.appendingPathComponent("compile"), title: "Compile: \(packageURL.deletingLastPathComponent().lastPathComponent)", in: workbench)
//    if !(spmProcConsole?.isReadingFromBuffer ?? true) {
//      spmProc.standardOutput = spmProcConsole?.output
//      spmProc.standardError = spmProcConsole?.output
//      spmProcConsole?.startReadingFromBuffer()
//      spmProcConsole?.writeLine(string: "Building: \(packageURL.deletingLastPathComponent().lastPathComponent)")
//    } else {
//      //The console is using by another process with the same representedObject
//      return
//    }
//    try? spmProc.run()
//    handler?(.running, spmProc)
//  }
//
//  func clean(in workbench: Workbench, handler: (() -> Void)?) {
//    guard let project = workbench.project, let package = findPackage(project: project) else { return  }
//
//    let proc = Process()
//    proc.currentDirectoryURL = package.url.deletingLastPathComponent()
//    proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
//    proc.arguments = ["package", "clean"]
//    var cleanConsole : Console?
//    proc.terminationHandler = { process in
//      cleanConsole?.writeLine(string: "Finished Cleaning \(package.url.deletingLastPathComponent().lastPathComponent)")
//      cleanConsole?.stopReadingFromBuffer()
//
//      handler?()
//    }
//    cleanConsole = self.openConsole(key: package.url.appendingPathComponent("clean"), title: "Clean: \(package.url.deletingLastPathComponent().lastPathComponent)", in: workbench)
//
//    if !(cleanConsole?.isReadingFromBuffer ?? true) {
//      proc.standardOutput = cleanConsole?.output
//      proc.standardError = cleanConsole?.output
//      cleanConsole?.startReadingFromBuffer()
//      cleanConsole?.writeLine(string: "Cleaning: \(package.url.deletingLastPathComponent().lastPathComponent)")
//    } else {
//      return
//    }
//    try? proc.run()
//  }
//
//
//}
//
//extension SPMBuildSystem : ConsoleSupport {}
//
//class SPMLauncher: Launcher {
//
//  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
//   guard let project = workbench.project, let package = findPackage(project: project) else {
//      handler?(.failed, nil)
//      return
//    }
//    let packageUrl = package.url
//
//    let programProc = Process()
//    programProc.currentDirectoryURL = packageUrl.deletingLastPathComponent()
//
//    programProc.environment = ["PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]
//
//    //Mock
////    let toolchain = "/Library/Developer/Toolchains/swift-5.1.4-RELEASE.xctoolchain/"
//    let toolchain = SKLocalServer.swiftToolchain
//    if !toolchain.isEmpty {
//      programProc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
//    } else {
//      programProc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
//    }
//
//    programProc.arguments = ["run", "--skip-build"]
//
//    var programProcConsole: Console?
//    programProc.terminationHandler = { process in
//      programProcConsole?.stopReadingFromBuffer()
//      handler?(.finished, process)
//    }
//
//    let name = packageUrl.deletingLastPathComponent().lastPathComponent
//    programProcConsole = openConsole(key: package, title: "Run: \(name)", in: workbench)
//    if !(programProcConsole?.isReadingFromBuffer ?? true) {
//      programProc.standardOutput = programProcConsole?.output
//      programProc.standardError = programProcConsole?.output
//      programProcConsole?.startReadingFromBuffer()
//    } else {
//      //The console is using by another process with the same representedObject
//      return
//    }
//
//
//    try? programProc.run()
//    handler?(.running, programProc)
//  }
//}
//
//extension SPMLauncher : ConsoleSupport {}
//
//
//fileprivate func findPackage(project: Project) -> File? {
//  for folder in project.folders {
//    guard let files = try? folder.files() else { continue }
//    if let package = files.first(where: {file in file.name.lowercased() == "package.swift"}) {
//      return package
//    }
//  }
//  return nil
//}
