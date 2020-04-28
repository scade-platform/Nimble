//
//  Target.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 27.04.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore

public struct Target {
  let name: String
  let icon: Icon? = nil
  let variants: [Variant] 
}

public struct Variant {
  
  let name: String
  let icon: Icon?
  let source: Any?
  
  let createRunProcess: (() -> Process?)?
}

extension Variant {
  var sourceName : String {
    switch self.source {
    case let folder as Folder:
      return "\(self.name) - \(folder.path.string)"
    case let file as File:
      return "\(self.name) - \(file.path.string)"
    default:
      return ""
    }
  }
}

