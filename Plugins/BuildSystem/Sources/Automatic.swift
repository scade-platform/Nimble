//
//  Automatic.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 21/02/2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore
import BuildSystem

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
  
  func run(_ variant: Variant) {
    variant.buildSystem?.run(variant)
  }
  
  func build(_ variant: Variant) {
     variant.buildSystem?.build(variant)
  }
  
  func clean(_ variant: Variant) {
    variant.buildSystem?.clean(variant)
  }
}

