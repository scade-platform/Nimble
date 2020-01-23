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
  func openConsole(title: String, in workbench: Workbench) -> Console? {
    guard let console = workbench.open(console: title) else {
      if let newConsole = workbench.createConsole(title: title, show: true) {
        return newConsole
      }
      return nil
    }
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
