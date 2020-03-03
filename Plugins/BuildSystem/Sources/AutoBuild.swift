//
//  AutoBuild.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 21/02/2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore


class AutoBuild: BuildSystem {
  
  var launcher: Launcher?
  
  public static let shared = AutoBuild()
  
  private init() {}
  
  var name: String {
    return "Automatic"
  }
  
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL, let system = buildSystem(for: fileURL, in: workbench) else {
      return
    }
    return system.run(in: workbench, handler: handler)
  }
  
  private func buildSystem(for file: URL, in workbench: Workbench) -> BuildSystem? {
    var buildSystem: BuildSystem? = nil
    let systems = BuildSystemsManager.shared.buildSystems.compactMap{$0 as? AutoBuildable}
    for system in systems {
      if system.canBuild(file: file, in: workbench) {
        buildSystem = system as? BuildSystem
      }
      if system.isDefault(for: file, in: workbench) {
        break
      }
    }
    launcher = buildSystem?.launcher
    return buildSystem
  }
  
  func clean(in workbench: Workbench, handler: (() -> Void)?) {
    guard let fileURL = workbench.currentDocument?.fileURL, let system = buildSystem(for: fileURL, in: workbench) else {
      return
    }
    return system.clean(in: workbench, handler: handler)
  }
}

public protocol AutoBuildable {
   func canBuild(file: URL, in workbench: Workbench?) -> Bool
   func isDefault(for file: URL, in workbench: Workbench?) -> Bool
}

public extension AutoBuildable {
   func canBuild(file: URL, in workbench: Workbench?) -> Bool {
     return false
   }
   
  func isDefault(for file: URL, in workbench: Workbench?) -> Bool {
     return false
   }
}

