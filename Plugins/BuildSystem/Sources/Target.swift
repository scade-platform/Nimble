//
//  Target.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 27.04.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore

public protocol Target {
  var name: String { get }
  var variants: [Variant] { get }
}

public struct Variant {
  let name: String
  let icon: Icon?
  
  let runHendler: ((Workbench) -> Void)?
  let buildHendler: ((Workbench) -> Void)?
  let cleanHendler: ((Workbench) -> Void)?
}
