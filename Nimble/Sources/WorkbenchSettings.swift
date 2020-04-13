//
//  Settings.swift
//  Nimble
//
//  Created by Grigory Markin on 11.04.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import NimbleCore
import KPCTabsControl

extension CloseButtonPosition: Codable {}

struct WorkbenchSettings: SettingsGroup {
  static let shared = WorkbenchSettings()

  @Setting("workbench.showFileIconsInTabs", defaultValue: true)
  var showFileIconsInTabs: Bool

  @Setting("workbench.tabCloseButtonPosition", defaultValue: .left)
  var tabCloseButtonPosition: CloseButtonPosition
}
