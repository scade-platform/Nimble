//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

// MARK: - BuildSystem base protocol

public protocol BuildSystem : class {
  var name: String { get }

  func targets(in workbench: Workbench) -> [Target]

  func run(_ variant: Variant)
  func build(_ variant: Variant)
  func clean(_ variant: Variant)
}


// MARK: - BuildSystemTask

public class BuildSystemTask: WorkbenchProcess {}


// MARK: - BuildSystemManager

public class BuildSystemsManager {
  public static let shared = BuildSystemsManager()
  
  public var observers = ObserverSet<BuildSystemsObserver>()

  public private(set) var buildSystems : [BuildSystem] = []

  public var activeBuildSystem: BuildSystem? = Automatic.shared {
    didSet {
      observers.notify{$0.activeBuildSystemDidChange(deactivatedBuildSystem: oldValue, activeBuildSystem: activeBuildSystem)}
    }
  }

  private init() {}

  public func register(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
    observers.notify{ $0.buildSystemDidRegister(buildSystem) }
  }
}

public protocol BuildSystemsObserver : class {
  func buildSystemDidRegister(_ buildSystem: BuildSystem)
  func activeBuildSystemDidChange(deactivatedBuildSystem: BuildSystem?, activeBuildSystem: BuildSystem?)

  func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?)
}

public extension BuildSystemsObserver {
  //Default implementations
  func buildSystemDidRegister(_ buildSystem: BuildSystem) {}
  func activeBuildSystemDidChange(deactivatedBuildSystem: BuildSystem?, activeBuildSystem: BuildSystem?) {}

  func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?) {}
}
