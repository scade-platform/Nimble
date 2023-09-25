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
