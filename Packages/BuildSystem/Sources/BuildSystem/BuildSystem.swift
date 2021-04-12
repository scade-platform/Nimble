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

  func run(_ variant: Variant)
  func build(_ variant: Variant)
  func clean(_ variant: Variant)

  func collectTargets(from workbench: Workbench) -> [Target]
}

extension BuildSystem {
  var id: ObjectIdentifier { ObjectIdentifier(self) }

  public func targets(in workbench: Workbench) -> [Target] {
    return BuildSystemsManager.shared.targets(in: workbench, from: self)
  }
}

// MARK: - BuildSystemTask

public protocol BuildTask: WorkbenchTask {}

public class BuildSystemTask: WorkbenchProcess, BuildTask {}



// MARK: - BuildSystemsManager

public class BuildSystemsManager {
  public struct WorkbenchTargets {
    var all: [Target] { byBuildSystem.values.flatMap{$0} }
    var byBuildSystem: [ObjectIdentifier: [Target]] = [:]

    fileprivate mutating func append(_ target: Target) {
      var targets = byBuildSystem[target.buildSystem.id, default: []]
      targets.append(target)
      byBuildSystem[target.buildSystem.id] = targets
    }
  }

  public static let shared = BuildSystemsManager()

  private var workbenchTargets: [ObjectIdentifier: WorkbenchTargets]  = [:]

  public var observers = ObserverSet<BuildSystemsObserver>()

  public private(set) var buildSystems : [BuildSystem] = []

  public var activeBuildSystem: BuildSystem? = Automatic.shared {
    didSet {
      observers.notify{ $0.activeBuildSystemDidChange(activeBuildSystem, deactivatedBuildSystem: oldValue)}
    }
  }

  private init() {}

  private func updateTargets(in workbench: Workbench) {
    var targets = WorkbenchTargets()
    let availableTargets = activeBuildSystem?.collectTargets(from: workbench) ?? []

    availableTargets.forEach { targets.append($0) }
    workbenchTargets[workbench.id] = targets

    workbench.selectedVariant = availableTargets.first?.variants.first

    observers.notify{ $0.availableTargetsDidChange(workbench) }
  }

  public func connect(to workbench: Workbench) {
    workbench.observers.add(observer: self)
    workbench.project?.observers.add(observer: self)
  }

  public func disconnect(from workbench: Workbench) {
    workbenchTargets.removeValue(forKey: workbench.id)
    observers.notify{ $0.availableTargetsDidChange(workbench) }

    workbench.observers.remove(observer: self)
    workbench.project?.observers.remove(observer: self)
  }

  public func register(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
    observers.notify{ $0.buildSystemDidRegister(buildSystem) }
  }

  public func targets(in workbench: Workbench) -> [Target] {
    return workbenchTargets[workbench.id]?.all ?? []
  }

  fileprivate func targets(in workbench: Workbench, from buildSystem: BuildSystem) -> [Target] {
    return workbenchTargets[workbench.id]?.byBuildSystem[buildSystem.id] ?? []
  }

}


// MARK: - BuildSystemsObserver

public protocol BuildSystemsObserver : class {
  func buildSystemDidRegister(_ buildSystem: BuildSystem)
  func activeBuildSystemDidChange(_ buildSystem: BuildSystem?, deactivatedBuildSystem: BuildSystem?)
  func availableTargetsDidChange(_ workbench: Workbench)
  func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?)
}

//Default implementations
public extension BuildSystemsObserver {
  func buildSystemDidRegister(_ buildSystem: BuildSystem) {}
  func activeBuildSystemDidChange(_ buildSystem: BuildSystem?, deactivatedBuildSystem: BuildSystem?) {}
  func availableTargetsDidChange(_ workbench: Workbench) {}
  func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?) {}
}


// MARK: - Extensions

public extension Workbench {
  var selectedVariant: Variant? {
    get { return selectedVariants[self.id] }
    set {
      guard selectedVariants[self.id] !== newValue  else { return }

      if newValue == nil {
        selectedVariants.removeValue(forKey: self.id)
      } else {
        selectedVariants[self.id] = newValue
      }

      BuildSystemsManager.shared.observers.notify {
        $0.workbenchDidChangeVariant(self, variant: newValue)
      }
    }
  }
}

private var selectedVariants: [ObjectIdentifier: Variant] = [:]


// MARK: - BuildSystemsManager + Observers

extension BuildSystemsManager: WorkbenchObserver {
  public func workbenchWillChangeProject(_ workbench: Workbench) {
    workbench.project?.observers.remove(observer: self)
  }

  public func workbenchDidChangeProject(_ workbench: Workbench) {
    updateTargets(in: workbench)
    workbench.project?.observers.add(observer: self)
  }
}

extension BuildSystemsManager: ProjectObserver {
  public func projectFoldersDidChange(_ project: Project) {
    guard let workbench = project.workbench else { return }
    updateTargets(in: workbench)
  }
}
