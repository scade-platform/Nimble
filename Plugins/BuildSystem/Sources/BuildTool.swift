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
  func canBuild(file: URL) -> Bool
  func isDefault(for file: URL) -> Bool
}

public extension BuildTool {
  //default implementation
  func canBuild(file: URL) -> Bool {
    return false
  }
  
  func isDefault(for file: URL) -> Bool {
    return false
  }
}

public protocol BuildProgress {
}


public class BuildToolsManager {
  public static let shared = BuildToolsManager()
  
  public private(set) var tools : [BuildTool] = []
  
  public var selectedTool: BuildTool? = AutomaticBuildTool.shared
  
  private init() {}
  
  public func add(buildTool: BuildTool) {
    tools.append(buildTool)
  }
}
