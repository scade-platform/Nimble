//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public protocol BuildSystem : class {
  var name: String { get }
  
  func targets(in workbench: Workbench) -> [Target]
  
  func run(_ variant: Variant)
  func build(_ variant: Variant)
  func clean(_ variant: Variant)
}


protocol ConsoleSupport {
   func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console?
}

extension ConsoleSupport {
  func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console? {
    let openedConsoles = workbench.openedConsoles
    guard let console = openedConsoles.filter({$0.title == title}).filter({$0.representedObject is T}).first(where: {($0.representedObject as! T) == key}) else {
      if var newConsole = workbench.createConsole(title: title, show: true, startReading: false) {
        newConsole.representedObject = key
        return newConsole
      }
      return nil
    }
    return console
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

extension Array where Element == BuildSystem {
  func targets(in workbench: Workbench) -> [Target] {
    return self.flatMap{$0.targets(in: workbench)}
  }
  
  func hasTargets(in workbench: Workbench) -> Bool {
    self.contains{!$0.targets(in: workbench).isEmpty}
  }
}

