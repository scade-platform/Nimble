//
//  BuildSystemsManager.swift
//  BuildSystemsManager
//
//  Copyright © 2023 SCADE Inc. All rights reserved.
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

import NimbleCore


fileprivate extension BuildSystem {
  var id: ObjectIdentifier { ObjectIdentifier(self) }
}


// Build systems manager
public class BuildSystemsManager: WorkbenchTaskObserver, WorkbenchObserver, ProjectObserver {
  public typealias TerminationHandler = (Bool) -> Void

  public static let shared = BuildSystemsManager()

  private var workbenchTargets: [ObjectIdentifier: TargetGroup]  = [:]

  public var observers = ObserverSet<BuildSystemsObserver>()

  public private(set) var buildSystems : [BuildSystem] = []

  private var activeBuildSystems: [ObjectIdentifier: BuildSystem] = [:]
  private var currentTask: BuildSystemTask? = nil
  private var currentTaskTerminationHandler: TerminationHandler? = nil

  private init() {}

  // Sets active build system in workbench
  public func setActiveBuildSystem(in workbench: Workbench, buildSystem: BuildSystem) {
    let oldBuildSystem = activeBuildSystems[workbench.id]
    activeBuildSystems[workbench.id] = buildSystem

    // notifying observers
    observers.notify{
      $0.activeBuildSystemDidChange(buildSystem, deactivatedBuildSystem: oldBuildSystem)}

    // updating targets
    updateTargets(in: workbench)
  }

  // Returns active build system for workbench
  public func activeBuildSystem(in workbench: Workbench) -> BuildSystem {
    return activeBuildSystems[workbench.id] ?? AutomaticBuildSystem.shared
  }

  private func selectVariant(id: String?, in workbench: Workbench) {
    if let id = id, let variant = workbenchTargets[workbench.id]?.findVariant(id: id) {
      workbench.selectedVariant = variant
    } else {
      workbench.selectedVariant = workbenchTargets[workbench.id]?.firstVariant()
    }
  }

  private func updateTargets(in workbench: Workbench) {
    // saving id of selected variant
    let selectedId = workbench.selectedVariant?.id

    // collecting targets for active build system
    let group = activeBuildSystem(in: workbench).collectTargets(workbench: workbench)

    // postprocessing collected target tree with all build systems
    for buildSystem in buildSystems {
      buildSystem.postprocessTargets(group: group)
    }

    workbenchTargets[workbench.id] = group
  
    // selecting variant using previously selected variant ID
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

  // Searches for variant with specified ID in workbench
  public func findVariant(workbench: Workbench, id: String) -> Variant? {
    return workbenchTargets[workbench.id]?.findVariant(id: id)
  }

  // Returns target tree for specified workbench
  public func targets(workbench: Workbench) -> TargetGroup {
    if let targets = workbenchTargets[workbench.id] {
      return targets
    }

    return TargetGroup(buildSystem: AutomaticBuildSystem.shared, name: "Empty Tree")
  }

  // // Returns all targets for build system
  // public func allTargets(workbench: Workbench, buildSystem: BuildSystem) -> [Target] {
  //   return workbenchTargets[workbench.id]?.targets[buildSystem.id]?.allTargets() ?? []
  // }

  // Returns all targets for all build systems in work bench
  public func allTargets(workbench: Workbench) -> [Target] {
    return workbenchTargets[workbench.id]?.allTargets() ?? []
  }

  // Starts building specified variant
  public func build(variant: Variant, terminationHandler: TerminationHandler? = nil) {
    // saving current document
    // TODO: do we really need it here?
    variant.target.workbench.saveAll(nil)

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

  public func workbenchWillChangeProject(_ workbench: Workbench) {
    workbench.project?.observers.remove(observer: self)
  }

  public func workbenchDidChangeProject(_ workbench: Workbench) {
    updateTargets(in: workbench)
    workbench.project?.observers.add(observer: self)
  }

  public func projectFoldersDidChange(_ project: Project) {
    guard let workbench = project.workbench else { return }
    updateTargets(in: workbench)
  }
}

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
