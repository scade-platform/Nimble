//
//  Target.swift
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


// Represents single item in the tree of targets
open class TargetTreeItem {
  // Parent group
  public private(set) weak var group: TargetGroup?

  // Item build system
  public private(set) weak var buildSystemRef: BuildSystem?

  // Item name
  public private(set) var name: String

  // Optional item for tree item
  public var icon: Icon? = nil

  // Initiazes target tree item with specified name and parent group
  public init(buildSystem: BuildSystem, name: String) {
    self.buildSystemRef = buildSystem
    self.name = name
  }

  // Returns reference to buildsystem for target
  public var buildSystem: BuildSystem {
    return buildSystemRef!
  }

  // Sets group for target
  fileprivate func setGroup(group: TargetGroup) {
    if self.group != nil {
      fatalError("Build target is already in group")
    }

    self.group = group
  }
}

// Separator int target tree
public class TargetSeparator: TargetTreeItem {
  // Initializes separator item
  public init(buildSystem: BuildSystem) {
    super.init(buildSystem: buildSystem, name: "")
  }
}

// Represents target group in the tree of targets
public class TargetGroup: TargetTreeItem {
  // Array of nested items
  public private(set) var items: [TargetTreeItem] = []

  // Initializes target group with specified name and optional parent group
  public override init(buildSystem: BuildSystem, name: String) {
    super.init(buildSystem: buildSystem, name: name)
  }

  // Returns true if group is empty
  public var isEmpty: Bool {
    return items.isEmpty
  }

  // Returns number of elements in group
  public var count: Int {
    return items.count
  }

  // Returns array of all targets
  public func allTargets() -> [Target] {
    var result: [Target] = []

    for item in items {
      if let variant = item as? Target {
        result.append(variant)
      } else if let group = item as? TargetGroup {
        result += group.allTargets()
      }
    }

    return result
  }

  // Adds item into group
  public func add(item: TargetTreeItem) {
    items.append(item)
    item.setGroup(group: self)
  }

  // Adds separator into group
  public func addSeparator() {
    items.append(TargetSeparator(buildSystem: buildSystem))
  }

  // Searches for variant with specified ID
  public func findVariant(id: String) -> Variant? {
    for item in items {
      if let target = item as? Target {
        return target.variants.find(id: id)
      } else if let group = item as? TargetGroup {
        if let variant = group.findVariant(id: id) {
          return variant
        }
      }
    }

    return nil
  }

  // Returns first variant in the list of variants
  public var firstVariant: Variant? {
    for item in items {
      if let target = item as? Target {
        if let variant = target.variants.first {
          return variant
        }
      } else if let group = item as? TargetGroup {
        if let variant = group.firstVariant {
          return variant
        }
      }
    }

    return nil
  }
}

open class Target: TargetTreeItem {
  // Weak reference to target workbench
  private weak var workbenchRef: Workbench?

  // Root group of variants for the target
  public var variants: VariantGroup

  // Initializes target with specified workbench, build system and target name
  public init(workbench: Workbench, buildSystem: BuildSystem, name: String) {
    self.workbenchRef = workbench
    self.variants = VariantGroup(name: name)
    super.init(buildSystem: buildSystem, name: name)
  }

  // Returns reference to workbench for target
  public var workbench: Workbench {
    return workbenchRef!
  }

  // Returns true if target contains specified file. Default implementation always returns false.
  open func contains(file: File) -> Bool {
    return false
  }

  // Returns true if target contains directory. Default implementation always returns false.
  open func contains(folder: Folder) -> Bool {
    return false
  }

  // Returns true if target contains file or folder located at specified URL
  public func contains(url: URL) -> Bool {
    guard url.isFileURL else { return false }
    if let folder = Folder(url: url) {
      return contains(folder: folder)
    } else if let file = File(url: url) {
      return contains(file: file)
    }
    return false
  }

  // Searches for variant with specified ID
  public func findVariant(id: String) -> Variant? {
    return variants.find(id: id)
  }
}
