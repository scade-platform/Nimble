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

  @SettingDefinition("workbench.showFileIconsInTabs", defaultValue: true)
  private(set) var showFileIconsInTabs: Bool

  @SettingDefinition("workbench.tabCloseButtonPosition", defaultValue: .left)
  private(set) var tabCloseButtonPosition: CloseButtonPosition
}
