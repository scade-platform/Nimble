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

extension Settings: SettingValidator {
  public func validateSetting<S, T>(_ setting: S) -> [SettingDiagnostic] where S : SettingProtocol, T == S.ValueType {
    switch setting {
    case $androidToolchainNdk:
      return validateAndroidToolchainNDK()
    default:
      return .valid
    }
  }
}

fileprivate extension Settings {
  func validateAndroidToolchainNDK() -> [SettingDiagnostic] {
    
    guard !androidToolchainNdk.isEmpty else {
      return [$androidToolchainNdk.error("Please specify location of Android NDK. If you haven’t installed NDK, following instructions here https://docs.scade.io/v2.0/docs/installation#install-android-ndk")]
    }
    
    guard let path = Path(androidToolchainNdk) else {
      return [$androidToolchainNdk.error("Path is not valid")]
    }
    
    guard path.exists, path.isDirectory else {
      return [$androidToolchainNdk.error("Cannot find Android NDK in the path. Please refer to https://docs.scade.io/v2.0/docs/installation#install-android-ndk for further instructions")]
    }
    
    //TODO: Check version of NDK. It should be at least 21
    return .valid
  }
}
