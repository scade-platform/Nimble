//
//  BuildTool.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public protocol BuildTool {
  var name: String { get }
  func run(in workbench: Workbench) -> BuildProgress
}

public protocol BuildProgress {
}


public class BuildToolsManager {
  public static let shared = BuildToolsManager()
  
  public private(set) var tools : [BuildTool] = []
  
  public var selectedTool: BuildTool? = nil
  
  private init() {}
  
  public func add(buildTool: BuildTool) {
    tools.append(buildTool)
    if selectedTool == nil {
      selectedTool = buildTool
    }
  }
 
}
