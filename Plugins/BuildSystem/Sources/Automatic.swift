//
//  Automatic.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 21/02/2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore


class Automatic: BuildSystem {
  
  
  public static let shared = Automatic()
  
  private init() {}
  
  var name: String {
    return "Automatic"
  }
  
  func targetsBySystem(in workbench: Workbench) -> [[Target]] {
    let systems = BuildSystemsManager.shared.buildSystems
    return systems.map{$0.targets(in: workbench)}
  }
  
  func targets(in workbench: Workbench) -> [Target] {
    let systems = BuildSystemsManager.shared.buildSystems
    return systems.flatMap{$0.targets(in: workbench)}
  }
  
  func run(_ variant: Variant, in workbench: Workbench) {
    variant.buildSystem?.run(variant, in: workbench)
  }
  
  func build(_ variant: Variant, in workbench: Workbench) {
     variant.buildSystem?.build(variant, in: workbench)
  }
  
  func clean(_ variant: Variant, in workbench: Workbench) {
    variant.buildSystem?.clean(variant, in: workbench)
  }
}

