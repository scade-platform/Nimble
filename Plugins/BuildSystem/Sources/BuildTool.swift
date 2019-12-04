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
  static var name: String { get }
  static func run(with config: [BuildConfigField: Any]) throws -> BuildProcess?
}

public protocol BuildProcess {
  var isRunning: Bool { get }
  func cancel()
}

public enum BuildConfigField {
  case file
  case working_dir
  case env
  case args
}


public class BuildToolsManager {
  public static let shared = BuildToolsManager()
  
  public private(set) var tools : [BuildTool.Type] = []
  
  private init() {}
  
  public func registerBuildToolClass<T: BuildTool>(_ buildToolClass: T.Type) {
    tools.append(buildToolClass)
  }
}
