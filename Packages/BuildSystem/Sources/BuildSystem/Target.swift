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

  var variantsGroups: [String] { get }

  var buildSystem: BuildSystem { get }

  var workbench: Workbench? { get }

  func contains(file: File) -> Bool

  func contains(folder: Folder) -> Bool

  // Group for a variant
  func group(for: Variant) -> UInt?

  // Group for another group. Nil is the top group
  func group(for: String) -> UInt?
}

public struct TargetRef {
  public private(set) weak var value: Target?
  public init(value: Target) { self.value = value }
}

public extension Target {
  var ref: TargetRef { TargetRef(value: self) }
}

public extension Target {
  var icon: Icon? { nil }

  var variantsGroups: [String] { [] }

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

  // Group variants into groups
  func group(for: Variant) -> UInt? { return nil }

  // Group another groups into sub-groups
  func group(for: String) -> UInt? { return nil }
}



public protocol Variant: AnyObject {
  var name: String { get }
  var icon: Icon? { get }
  var target: Target? { get }
  
  func run() throws -> WorkbenchTask
  func build() throws -> WorkbenchTask
  func clean() throws -> WorkbenchTask
}

public struct VariantRef {
  public private(set) weak var value: Variant?
  public init(value: Variant) { self.value = value }
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

  var ref: VariantRef { VariantRef(value: self) }
}


public extension Variant {
  var buildSystem: BuildSystem? { target?.buildSystem }
}

public enum VariantError: Error {
  case operationNotSupported
  case targetRequired
}
