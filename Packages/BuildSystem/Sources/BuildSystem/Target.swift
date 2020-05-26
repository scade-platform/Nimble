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

  func contains(folder: Folder) -> Bool
}

public extension Target {
  var icon: Icon? { nil }

  var workbench: Workbench? { nil }

  var id: ObjectIdentifier { ObjectIdentifier(self) }
  
  func contains(file: File) -> Bool { return false }

  func contains(folder: Folder) -> Bool { return false }

  func contains(url: URL) -> Bool {
    guard url.isFileURL else { return false }
    if let folder = Folder(url: url) {
      return contains(folder: folder)
    } else if let file = File(url: url) {
      return contains(file: file)
    }
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
