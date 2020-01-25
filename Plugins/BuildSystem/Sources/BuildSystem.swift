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
  func run(in workbench: Workbench) -> BuildProgress
}

extension BuildSystem {
  func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console? {
    let openedConsoles = workbench.openedConsoles
    guard let console = openedConsoles.filter({$0.representedObject is T}).first(where: {($0.representedObject as! T) == key}) else {
      if var newConsole = workbench.createConsole(title: title, show: true) {
        newConsole.representedObject = key
        return newConsole
      }
      return nil
    }
    console.startReadingFromBuffer()
    return console
  }
}

public protocol BuildProgress {
}

public class BuildSystemsManager {
  public static let shared = BuildSystemsManager()
  
  public private(set) var buildSystems : [BuildSystem] = []
  
  public var activeBuildSystem: BuildSystem? = nil
  
  private init() {}
  
  public func add(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
    if activeBuildSystem == nil {
      activeBuildSystem = buildSystem
    }
  }
 
}
