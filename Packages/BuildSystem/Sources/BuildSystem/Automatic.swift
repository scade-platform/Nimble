//
//  Automatic.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 21/02/2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore

public class Automatic: BuildSystem {
  public static let shared = Automatic()
  
  private init() {}
  
  public var name: String {
    return "Automatic"
  }

  public func collectTargets(from workbench: Workbench) -> [Target] {    
    return BuildSystemsManager.shared.buildSystems.flatMap{
      $0.collectTargets(from: workbench)      
    }
  }
  
  public func run(_ variant: Variant) {
    variant.buildSystem?.run(variant)
  }
  
  public func build(_ variant: Variant) {
     variant.buildSystem?.build(variant)
  }
  
  public func clean(_ variant: Variant) {
    variant.buildSystem?.clean(variant)
  }
}

