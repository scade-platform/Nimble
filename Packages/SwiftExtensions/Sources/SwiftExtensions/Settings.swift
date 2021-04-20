//
//  Settings.swift
//  
//
//  Created by Grigory Markin on 07.04.21.
//

import Foundation
import NimbleCore

public struct Settings: SettingsGroup {
  public static var shared = Settings()
  
  @SettingDefinition("swift.toolchain", defaultValue: "")
  public var swiftToolchain: String

  @SettingDefinition("swift.platforms", defaultValue: [])
  public var platforms: [SwiftToolchain]

  @SettingDefinition("com.android.toolchain.swift", defaultValue: "")
  public var androidSwiftCompiler: String

  @SettingDefinition("com.android.toolchain.sdk", defaultValue: "")
  public var androidToolchainSdk: String

  @SettingDefinition("com.android.toolchain.ndk", defaultValue: "")
  public var androidToolchainNdk: String
}
