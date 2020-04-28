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
  
  func targets(from workbench: Workbench) -> [Target]
  
  func run(_ variant: Variant, in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?)
  func build(_ variant: Variant, in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?)
  func clean(_ variant: Variant, in workbench: Workbench, handler: (() -> Void)?)
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

public class BuildSystemsManager {
  public static let shared = BuildSystemsManager()
  
  public private(set) var buildSystems : [BuildSystem] = []
  
  public var activeBuildSystem: BuildSystem? = nil
  
  private init() {}
  
  public func add(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
  }
 
}

extension Array where Element == BuildSystem {
  func targets(for workbench: Workbench) -> [Target] {
    let allTargets = self.flatMap{$0.targets(from: workbench)}
    return allTargets.reduce([]) { result, target -> [Target] in
      guard let accTarget = result.first(where: {$0 == target} ) else {
        return result + [target]
      }
      let newAccTarget = Target(name: target.name, icon: target.icon, variants: accTarget.variants + target.variants)
      return result.filter{$0.name != target.name} + [newAccTarget]
    }
  }
  
  func hasTargets(for workbench: Workbench) -> Bool {
    self.contains{!$0.targets(from: workbench).isEmpty}
  }
}
