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
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?)
  func clean(in workbench: Workbench, handler: (() -> Void)?)
}

public extension BuildSystem {
  func run(in workbench: Workbench) {
    self.run(in: workbench, handler: nil)
  }
  
  func clean(in workbench: Workbench) {
    self.clean(in: workbench, handler: nil)
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
  
  public var activeBuildSystem: BuildSystem? = AutoBuild.shared
  
  private init() {}
  
  public func add(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
  }
 
}
