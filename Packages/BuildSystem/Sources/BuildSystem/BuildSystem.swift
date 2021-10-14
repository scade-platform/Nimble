//
//  BuildSystem.swift
//  BuildSystem
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

    var groupedByName: [(String, [Target])] {
      var groups: [String: [Target]] = [:]

      // Group targets by name
      all.forEach {
        var targets = groups[$0.name] ?? []
        targets.append($0)
        groups.updateValue(targets, forKey: $0.name)
      }

      return groups
        .map{($0.key, $0.value.sorted(by: { t1, t2 in t1.buildSystem.name.lowercased() < t2.buildSystem.name.lowercased()}))}
        .sorted{$0.0.lowercased() < $1.0.lowercased()}
    }

    fileprivate mutating func append(_ target: Target) {
      var targets = byBuildSystem[target.buildSystem.id, default: []]
      targets.append(target)
      byBuildSystem[target.buildSystem.id] = targets
    }

    func find(variant: (name: String, target: String, system: String)) -> Variant? {
      let target = all.filter{$0.name == variant.target && $0.buildSystem.name == variant.system}.first
      return target?.variants.first{ $0.name == variant.name }
    }
  }

  public static let shared = BuildSystemsManager()

  private var workbenchTargets: [ObjectIdentifier: WorkbenchTargets]  = [:]

  public var observers = ObserverSet<BuildSystemsObserver>()

  public private(set) var buildSystems : [BuildSystem] = []

  public var activeBuildSystem: BuildSystem? = Automatic.shared {
    didSet {
      observers.notify{
        $0.activeBuildSystemDidChange(activeBuildSystem, deactivatedBuildSystem: oldValue)}
    }
  }

  private init() {}

  private func selectVariant(_ fqn: (String, String, String)?, in workbench: Workbench) {
    guard let targets = workbenchTargets[workbench.id]?.groupedByName else { return }

    if let fqn = fqn, let variant = workbenchTargets[workbench.id]?.find(variant: fqn) {
      workbench.selectedVariant = variant
    } else {
      workbench.selectedVariant = targets.first?.1.first?.variants.first
    }
  }

  private func updateTargets(in workbench: Workbench) {
    // Store selected variant's "fqn"
    let selectedFQN = workbench.selectedVariant?.fqn

    // Load targets
    var targets = WorkbenchTargets()
    activeBuildSystem?.collectTargets(from: workbench).forEach {
      targets.append($0)
    }
    workbenchTargets[workbench.id] = targets

    // Update selection using stored "fqn"
    selectVariant(selectedFQN, in: workbench)

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

  public func find(variant: (name: String, target: String, system: String), in workbench: Workbench) -> Variant? {
    return workbenchTargets[workbench.id]?.find(variant: variant)
  }

  public func targets(in workbench: Workbench) -> [Target] {
    return workbenchTargets[workbench.id]?.all ?? []
  }

  public func targetsGroupedByName(in workbench: Workbench) -> [(String, [Target])] {
    return workbenchTargets[workbench.id]?.groupedByName ?? []
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
    get { return selectedVariants[self.id]?.value }
    set {
      guard selectedVariants[self.id]?.value !== newValue  else { return }

      if newValue == nil {
        selectedVariants.removeValue(forKey: self.id)
      } else {
        selectedVariants[self.id] = newValue?.ref
      }

      BuildSystemsManager.shared.observers.notify {
        $0.workbenchDidChangeVariant(self, variant: newValue)
      }
    }
  }
}

private var selectedVariants: [ObjectIdentifier: VariantRef] = [:]


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
