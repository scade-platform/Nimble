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


public protocol BuildSystemTask: WorkbenchTask {
  // Build task result
  var result: Bool { get }
}

extension WorkbenchProcess: BuildSystemTask {
  // Returns true if process is terminated with exit code 0
  public var result: Bool {
    return terminationStatus == 0
  }
}

// Represents abstract build system registered in build system manager
public protocol BuildSystem: AnyObject {
  // Build system name
  var name: String { get }

  // Collects and returns targets for workbench
  func collectTargets(workbench: Workbench) -> TargetGroup

  // Postprocess targets collected from other build systems
  func postprocessTargets(group: TargetGroup)
}

public extension BuildSystem {
  func postprocessTargets(group: TargetGroup) {}
}

fileprivate extension BuildSystem {
  var id: ObjectIdentifier { ObjectIdentifier(self) }
}

// Build system manager
public class BuildSystemsManager: WorkbenchTaskObserver {
  public struct WorkbenchTargets {
    // All targets grouped by build system
    var targets: [ObjectIdentifier: TargetGroup] = [:]

    // Root target tree items from all build systems grouped by target name
    var rootTargets: [String: [TargetTreeItem]] = [:]

    // Searches for variant with specified ID
    public func findVariant(id: String) -> Variant? {
      for (_, group) in targets {
        if let variant = group.findVariant(id: id) {
          return variant
        }
      }

      return nil
    }

    // Returns first variant in the list of all variants
    public var firstVariant: Variant? {
      for (_, group) in targets {
        if let variant = group.firstVariant {
          return variant
        }
      }

      return nil
    }

    // Add targets for build system
    public mutating func addTargets(buildSystemId: ObjectIdentifier, targets: TargetGroup) {
      self.targets[buildSystemId] = targets

      // collecting root targets and adding them into the rootTargets dictionary
      for targ in targets.items {
        var newItems: [TargetTreeItem] = rootTargets[targ.name] ?? []
        newItems.append(targ)
        newItems.sort(by: { $0.buildSystem.name.lowercased() < $1.buildSystem.name.lowercased() })
        rootTargets[targ.name] = newItems
      }
    }
  }

  public typealias TerminationHandler = (Bool) -> Void

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

  private var currentTask: BuildSystemTask? = nil
  private var currentTaskTerminationHandler: TerminationHandler? = nil

  private init() {}

  private func selectVariant(id: String?, in workbench: Workbench) {
    if let id = id, let variant = workbenchTargets[workbench.id]?.findVariant(id: id) {
      workbench.selectedVariant = variant
    } else {
      workbench.selectedVariant = workbenchTargets[workbench.id]?.firstVariant
    }
  }

  private func updateTargets(in workbench: Workbench) {
    // Store selected variant's "fqn"
    let selectedId = workbench.selectedVariant?.id

    var targets = WorkbenchTargets()

    // collecting targets for all build systems
    for buildSystem in buildSystems {
      let bsTargets = buildSystem.collectTargets(workbench: workbench)
      targets.addTargets(buildSystemId: buildSystem.id, targets: bsTargets)
    }

    // postprocessing targets for all build systems
    for (_, targets) in targets.targets {
      for buildSystem in buildSystems {
        buildSystem.postprocessTargets(group: targets)
      }
    }

    workbenchTargets[workbench.id] = targets

    // Update selection using previously selected variant ID
    selectVariant(id: selectedId, in: workbench)

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

  // Searches for variant with specified ID
  public func findVariant(workbench: Workbench, id: String) -> Variant? {
    return workbenchTargets[workbench.id]?.findVariant(id: id)
  }

  // Returns dictionary of root targets grouped by name
  public func rootTargets(workbench: Workbench) -> [String: [TargetTreeItem]] {
    return workbenchTargets[workbench.id]?.rootTargets ?? [:]
  }

  // Returns all targets for build system
  public func allTargets(workbench: Workbench, buildSystem: BuildSystem) -> [Target] {
    return workbenchTargets[workbench.id]?.targets[buildSystem.id]?.allTargets() ?? []
  }

  // Returns all targets for all build systems
  public func allTargets(workbench: Workbench) -> [Target] {
    guard let workbenchTargets = workbenchTargets[workbench.id] else { return [] }

    var result: [Target] = []
    for (_, group) in workbenchTargets.targets {
      result += group.allTargets()
    }

    return result
  }

  // Starts building specified variant
  public func build(variant: Variant, terminationHandler: TerminationHandler? = nil) {
    // saving current document
    // TODO: do we really need it here?
    variant.target.workbench.currentDocument?.save(nil)

    startBuildTask(variant: variant,
                   actionName: "Build",
                   createTask: { return variant.build(output: $0) },
                   terminationHandler: terminationHandler)
  }

  // Launches specified variant
  public func run(variant: Variant, terminationHandler: TerminationHandler? = nil) {
    // building variant before launching
    build(variant: variant) { result in
      if result {
        self.startBuildTask(variant: variant,
                            actionName: "Run",
                            createTask: { return variant.run(output: $0) },
                            terminationHandler: terminationHandler)
      }
    }
  }

  // Cleans specified variant
  public func clean(variant: Variant, terminationHandler: TerminationHandler? = nil) {
    startBuildTask(variant: variant,
                   actionName: "Clean",
                   createTask: { return variant.clean(output: $0) },
                   terminationHandler: terminationHandler)
  }

  // Starts build task (build, run, clean)
  private func startBuildTask(variant: Variant,
                              actionName: String,
                              createTask: (Console) -> BuildSystemTask,
                              terminationHandler: TerminationHandler? = nil) {
    assert(currentTask == nil)
 
    // opening console for build task
    let consoleName = "\(actionName): \(variant.id)"
    let console = ConsoleUtils.openConsole(key: consoleName, title: consoleName, in: variant.target.workbench)!
    console.writeLine(string: "\(actionName): \(variant.id)")

    // creating build task
    let task = createTask(console)

    do {
      // publishing task
      variant.target.workbench.publish(task: task)

      // saving current task and termination handler
      currentTask = task
      currentTaskTerminationHandler = terminationHandler

      // observing task to execute termination handler
      task.observers.add(observer: self)

      // starting task
      try task.run()
    }
    catch {
      console.writeLine(string: "Can't start build task: \(error)")
    }
  }

  public func taskDidFinish(_ task: WorkbenchTask, result: Bool) {
    assert(currentTask === task, "invalid current build task")
    currentTask = nil
    currentTaskTerminationHandler?(result)
  }
}


// MARK: - BuildSystemsObserver

public protocol BuildSystemsObserver : AnyObject {
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
