//
//  Settings.swift
//  
//
//  Created by Grigory Markin on 07.04.21.
//

import Foundation
import NimbleCore

public struct Settings: SettingsGroup {
  public static let shared = Settings()
  
  @SettingDefinition("swift.toolchain", defaultValue: "")
  public private(set) var swiftToolchain: String

  @SettingDefinition("swift.platforms", defaultValue: [])
  public private(set) var platforms: [SwiftToolchain]

  @SettingDefinition("com.android.toolchain.swift", defaultValue: "")
  public private(set) var androidSwiftCompiler: String

  @SettingDefinition("com.android.toolchain.sdk", defaultValue: "")
  public private(set) var androidToolchainSdk: String

  @SettingDefinition("com.android.toolchain.ndk", defaultValue: "")
  public private(set) var androidToolchainNdk: String
}
