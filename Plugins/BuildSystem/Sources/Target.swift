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
  var source: Source? { get }
  var workbench: Workbench? { get }
}

public extension Target {
  //Default value for optional properties
  var icon: Icon? { nil }
  var source: Any? { nil }
  var workbench: Workbench? { nil }
}

extension Target {
  var sourceName: String {
    " \(workbench?.project?.path?.string) : \(self.name) : \(source?.path.string)"
  }
}

public protocol Source {
  var path: Path { get }
}

extension FileSystemElement : Source {}

class TargetImpl : Target {
  let name: String
  var variants: [Variant]
  let source: Source?
  weak var workbench: Workbench?
  
  init(name: String, source: Source? = nil, workbench: Workbench? = nil, variants: [Variant] = []) {
    self.name = name
    self.source = source
    self.workbench = workbench
    self.variants = variants
    for var variant in variants {
      variant.target = self
    }
  }
}

public protocol Variant {
  var name: String { get }
  var icon: Icon? { get }
  var target: Target? { get set }
  
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
  case sourceRequired
}

public enum VariantTypeError<T>: Error {
  case unexpectedSourceType(get: Any?, expected: T.Type)
}

