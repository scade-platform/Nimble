//
//  Variant.swift
//  BuildSystem
//
//  Copyright © 2023 SCADE Inc. All rights reserved.
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

// Represents single item in the tree of variants for a target
open class VariantTreeItem {
  // Item name
  public private(set) var name: String

  // Optional item for tree item
  public var icon: Icon? = nil

  // Initiazes variant tree item with specified name and parent group
  public init(name: String) {
    self.name = name
  }
}

// Separator in variant tree
public class VariantSeparator: VariantTreeItem {
  // Initializes separator item
  public init() {
    super.init(name: "")
  }
}

// Represents group of variants in a tree of variants for a target
public class VariantGroup: VariantTreeItem {
  // Array of nested items
  public private(set) var items: [VariantTreeItem] = []

  // Initializes variant group with specified name and optional parent group
  public override init(name: String) {
    super.init(name: name)
  }

  // Returns true if group is empty
  public var isEmpty: Bool {
    return items.isEmpty
  }

  // Returns number of elements in group
  public var count: Int {
    return items.count
  }

  // Returns array of all variants
  public func allVariants() -> [Variant] {
    var result: [Variant] = []

    for item in items {
      if let variant = item as? Variant {
        result.append(variant)
      } else if let group = item as? VariantGroup {
        result += group.allVariants()
      }
    }

    return result
  }

  // Recursively searches for variant with specified ID
  public func find(id: String) -> Variant? {
    for item in items {
      if let variant = item as? Variant, variant.id == id {
        return variant
      } else if let group = item as? VariantGroup {
        return group.find(id: id)
      }
    }

    return nil
  }

  // Returns first variant in variant tree
  public var first: Variant? {
    for item in items {
      if let variant = item as? Variant {
        return variant
      } else {
        let group = item as! VariantGroup
        if let variant = group.first {
          return variant
        }
      }
    }

    return nil
  }

  // Adds variant into group
  public func add(item: VariantTreeItem) {
    items.append(item)
  }

  // Adds separator into group
  public func addSeparator() {
    add(item: VariantSeparator())
  }
}

// Represents build variant for a target
open class Variant: VariantTreeItem {
  // Weak reference to target for this variant
  private weak var targetRef: Target?

  // Unique ID of variant
  public private(set) var id: String

  // Initializes variant for specified target and with specified id, name and optional parent group.
  // Adds variant into target
  public init(target: Target, id: String, name: String) {
    self.targetRef = target
    self.id = id
    super.init(name: name)
  }

  // Returns reference to target for this variant
  open var target: Target {
    return targetRef!
  }

  // Returns reference to build system for this variant
  public var buildSystem: BuildSystem {
    return target.buildSystem
  }

  // Creates build task for target variant
  open func build(output: Console) -> BuildSystemTask {
    fatalError("should be overriden in derviced classes")
  }

  // Creates run task for target variant
  open func run(output: Console) -> BuildSystemTask {
    fatalError("should be overriden in derviced classes")
  }

  // Creates clean task for target variant
  open func clean(output: Console) -> BuildSystemTask {
    fatalError("should be overriden in derviced classes")
  }

  // Returns true if variant has run action. Default implementation always return false
  open func canRun() -> Bool {
    return false
  }
}

// Helper wrapper for weak reference to variant
struct VariantRef {
  public weak var value: Variant?

  public init(value: Variant?) {
    self.value = value
  }
}

extension Variant {
  var ref: VariantRef {
    return VariantRef(value: self)
  }
}
