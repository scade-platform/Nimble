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

public class BuildSystemsManager {
  public static let shared = BuildSystemsManager()

  public private(set) var buildSystems : [BuildSystem] = []

  public var activeBuildSystem: BuildSystem? = nil

  private init() {}

  public func add(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
  }

}

