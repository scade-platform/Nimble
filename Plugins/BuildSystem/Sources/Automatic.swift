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
  
  func targets(in workbench: Workbench) -> [Target] {
     //TODO: Add logic
    return []
   }
   
   func run(_ variant: Variant, in workbench: Workbench) {
      //TODO: Add logic
    }
   
   func build(_ variant: Variant, in workbench: Workbench) {
     //TODO: Add logic
   }
   
   func clean(_ variant: Variant, in workbench: Workbench) {
     //TODO: Add logic
   }
   
  
//  func run(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?) {
//    guard let system = buildSystem(in: workbench) else {
//      return
//    }
//    return system.run(in: workbench, handler: handler)
//  }
//
//  private func buildSystem(in workbench: Workbench) -> BuildSystem? {
//    let systems = BuildSystemsManager.shared.buildSystems
//    //result is tuple
//    //0 - build system, 1 - current priority
//    var result: (BuildSystem?, Int) = (nil, Int.max)
//    for system in systems {
//
//      //if system can handle whole project
//      if let project = workbench.project, system.canHandle(project: project) {
//        if result.1 > 0 {
//          //than select this build system
//          result = (system, 0)
//          break
//        }
//      }
//
//      //if system can handle one of project's folder
//      for folder in workbench.project?.folders ?? [] {
//        if system.canHandle(folder: folder) {
//          //and result priority larger
//          if result.1 > 1 {
//            //than select this build system
//            result = (system, 1)
//          }
//        }
//      }
//
//      //if system can handle one of opened document
//      for document in workbench.documents {
//        if let url = document.fileURL, let file = File(url: url), system.canHandle(file: file) {
//          //than select this build system
//          if result.1 > 2 {
//            result = (system, 2)
//          }
//        }
//      }
//    }
//    self.launcher = result.0?.launcher
//    return result.0
//  }
//
//  func clean(in workbench: Workbench, handler: (() -> Void)?) {
//    guard let system = buildSystem(in: workbench) else {
//      return
//    }
//    return system.clean(in: workbench)
//  }
}

