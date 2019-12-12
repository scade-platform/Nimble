//
//  BuildTool.swift
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

public protocol BuildProgress {
}


public class BuildToolsManager {
  public static let shared = BuildToolsManager()
  
  public private(set) var systems : [BuildSystem] = []
  
  public var selectedSystem: BuildSystem? = nil
  
  private init() {}
  
  public func add(buildSystem: BuildSystem) {
    systems.append(buildSystem)
    if selectedSystem == nil {
      selectedSystem = buildSystem
    }
  }
 
}
