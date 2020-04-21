//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public protocol BuildSystem {
  var name: String { get }
  var launcher: Launcher? { get }
  func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?)
  func clean(in workbench: Workbench, handler: (() -> Void)?)
  
  func canHandle(file: File) -> Bool
  func canHandle(folder: Folder) -> Bool
  func canHandle(project: Project) -> Bool
}

public extension BuildSystem {
  func run(in workbench: Workbench) {
    self.run(in: workbench, handler: nil)
  }
  
  func clean(in workbench: Workbench) {
    self.clean(in: workbench, handler: nil)
  }
  
  func canHandle(file: File) -> Bool {
    return false
  }
  
  func canHandle(folder: Folder) -> Bool {
    return false
  }
  
  func canHandle(project: Project) -> Bool {
    return false
  }
}

protocol ConsoleSupport {
   func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console?
}

extension ConsoleSupport {
  func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console? {
    let openedConsoles = workbench.openedConsoles
    guard let console = openedConsoles.filter({$0.representedObject is T}).first(where: {($0.representedObject as! T) == key}) else {
      if var newConsole = workbench.createConsole(title: title, show: true, startReading: false) {
        newConsole.representedObject = key
        return newConsole
      }
      return nil
    }
    return console
  }
}


public enum BuildStatus {
  case running
  case finished
  case failed
}

public protocol Launcher {
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?)
}

public extension Launcher {
  func launch(in workbench: Workbench) {
    self.launch(in: workbench, handler: nil)
  }
}

public class BuildSystemsManager {
  public static let shared = BuildSystemsManager()
  
  public private(set) var buildSystems : [BuildSystem] = []
  
  public var activeBuildSystem: BuildSystem? = Automatic.shared
  
  private init() {}
  
  public func add(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
  }
 
}

extension BuildSystemsManager: LaunchPlatformProvider {
  public func targets(for workbench: Workbench) -> [Target] {
    var result: [Target] = []
    var projectLaunchers: [LaunchPlatform] = []
    var folderLaunchers: [Folder: [LaunchPlatform]] = [:]
    for buildSystem in buildSystems {
      
      if let project = workbench.project, buildSystem.canHandle(project: project) {
        if let platform = buildSystem as? LaunchPlatform {
          projectLaunchers.append(platform)
        }
        
      }
      
      //if system can handle one of project's folder
      for folder in workbench.project?.folders ?? [] {
        if buildSystem.canHandle(folder: folder), let platform = buildSystem as? LaunchPlatform {
          if folderLaunchers[folder] == nil {
            folderLaunchers[folder] = []
          }
          folderLaunchers[folder]?.append(platform)
        }
      }
    }
    
    if !projectLaunchers.isEmpty, let project = workbench.project {
      let projectTarget = Target(project: project, name: project.path?.string ?? "project", icon: nil, platforms: projectLaunchers)
      result.append(projectTarget)
    }
    
    for (folder, platforms) in folderLaunchers {
      let folderTarget = Target(project: workbench.project , name: folder.name, icon: nil, platforms: platforms)
      result.append(folderTarget)
    }
    return result
  }
  
}
