//
//  Target.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 27.04.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation
import NimbleCore

public protocol Target : class {
  var name: String { get }
  var icon: Icon? { get }
  var variants: [Variant] { get }
  var workbench: Workbench? { get }
  
  func contains(file: File) -> Bool
}

public extension Target {
  //Default value for optional properties
  var icon: Icon? { nil }
  var workbench: Workbench? { nil }
  var id: ObjectIdentifier { ObjectIdentifier(self) }
  
  func contains(file: File) -> Bool {
    return false
  }
}

public protocol Variant {
  var name: String { get }
  var icon: Icon? { get }
  var target: Target? { get }
  var buildSystem: BuildSystem? { get }
  
  func run() throws -> WorkbenchTask
  func build() throws -> WorkbenchTask
  func clean() throws -> WorkbenchTask
}

public extension Variant {
  //Default value for optional properties
  var icon: Icon? { nil }
  var target: Target? { nil }
  
  //Default implementation
  func run() throws -> WorkbenchTask {
    throw VariantError.operationNotSupported
  }
  
  func build() throws -> WorkbenchTask {
    throw VariantError.operationNotSupported
  }
  
  func clean() throws -> WorkbenchTask {
    throw VariantError.operationNotSupported
  }
}

public enum VariantError: Error {
  case operationNotSupported
  case targetRequired
}
