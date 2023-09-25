//
//  AutomaticBuildSystem.swift
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

public class AutomaticBuildSystem: BuildSystem {
  public static let shared = AutomaticBuildSystem()
  
  private init() {}
  
  public var name: String {
    return "AutomaticBuildSystem"
  }

  public func collectTargets(workbench: Workbench) -> TargetGroup {
    // collecting targets for all build systems
    let groups = BuildSystemsManager.shared.buildSystems.map{ $0.collectTargets(workbench: workbench) }

    // collecting all root items into dictionary
    var rootItems: [String: [TargetTreeItem]] = [:]
    for group in groups {
      for item in group.items {
        rootItems[item.name] = (rootItems[item.name] ?? []) + [item]
      }
    }

    // creating root group for targets tree
    let rootGroup = TargetGroup(buildSystem: AutomaticBuildSystem.shared, name: "Automatic")

    // adding items into root group
    for (name, items) in rootItems {
      if items.count > 1 {
        // creating group for items
        let itemsGroup = TargetGroup(buildSystem: AutomaticBuildSystem.shared, name: name)
        itemsGroup.icon = IconsManager.icon(systemSymbolName: "square.on.square")

        // adding items for each build system sorting by build system name
        for item in items.sorted(by: {$0.buildSystem.name < $1.buildSystem.name }) {
          item.name = item.buildSystem.name
          itemsGroup.add(item: item)
        }

        // adding group into the root group
        rootGroup.add(item: itemsGroup)
      } else {
        // no merging required
        rootGroup.add(item: items[0])
      }
    }

    return rootGroup
  }
}

