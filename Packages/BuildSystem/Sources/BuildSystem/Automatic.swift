//
//  Automatic.swift
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

