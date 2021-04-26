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

  @SettingDefinition("com.android.toolchain.sdk",
                     description: "Path to the directory with Android SDK.",
                     defaultValue: "",
                     validator: AndroidSDKValidator())
  public private(set) var androidToolchainSdk: String

  @SettingDefinition("com.android.toolchain.ndk",
                     description: "Path to the directory with Android NDK.",
                     defaultValue: "",
                     validator: AndroidNDKValidator())
  public private(set) var androidToolchainNdk: String
}

fileprivate extension Settings {
  struct AndroidNDKValidator: SettingValidator {
    
    @Setting("com.android.toolchain.ndk")
    private var androidToolchainNdk: String
    
    
    func validateSetting<S: SettingProtocol, T>(_ setting: S) -> [SettingDiagnostic] where S.ValueType == T {
      guard setting == $androidToolchainNdk else {
        return .valid
      }
      
      guard !androidToolchainNdk.isEmpty else {
        return [$androidToolchainNdk.error("Please specify location of Android NDK. If you haven’t installed NDK, following instructions here https://docs.scade.io/v2.0/docs/installation#install-android-ndk")]
      }
      
      guard let path = Path(androidToolchainNdk) else {
        return [$androidToolchainNdk.error("Path is not valid")]
      }
      
      guard path.exists, path.isDirectory else {
        return [$androidToolchainNdk.error("Cannot find Android NDK in the path. Please refer to https://docs.scade.io/v2.0/docs/installation#install-android-ndk for further instructions.")]
      }
      
      let sourcePropertiesPath = path/"source.properties"
      guard let version = findVersion(from: sourcePropertiesPath) else {
        return [$androidToolchainNdk.warning("Cannot find Android NDK version to validate. Required version is 21 or higher.")]
      }
      
      let targetVersion = "21.0.0"
      guard  version.compare(targetVersion, options: .numeric) == .orderedDescending ||  version.compare(targetVersion, options: .numeric) == .orderedSame else {
        return [$androidToolchainNdk.warning("Android NDK version is \"\(version)\". Required version is 21 or higher.")]
      }
      
      return .valid
    }
    
    private func findVersion(from sourcePropertiesPath: Path) -> String? {
      guard sourcePropertiesPath.exists, sourcePropertiesPath.isFile, let content = try? String(contentsOf: sourcePropertiesPath) else {
        return nil
      }
      
      let lines = content.split(separator: "\n")
      
      guard let revision = lines.first(where: {$0.lowercased().hasPrefix("pkg.revision")}) else {
        return nil
      }
      
      var version = String(revision[revision.index(after: revision.firstIndex(of: "=")!)...])
      version = version.trimmingCharacters(in: CharacterSet(charactersIn: " "))
      return version
    }
  }
  
  struct AndroidSDKValidator: SettingValidator {
    
    @Setting("com.android.toolchain.sdk")
    private var androidToolchainSdk: String
    
    func validateSetting<S: SettingProtocol, T>(_ setting: S) -> [SettingDiagnostic] where S.ValueType == T {
      guard setting == $androidToolchainSdk else {
        return .valid
      }
      
      guard !androidToolchainSdk.isEmpty else {
        return [$androidToolchainSdk.error("Please specify location of Android SDK. If you haven’t installed SDK, following instructions here https://docs.scade.io/v2.0/docs/installation#configure-sdk")]
      }
      
      guard let path = Path(androidToolchainSdk) else {
        return [$androidToolchainSdk.error("Path is not valid")]
      }
      
      guard path.exists, path.isDirectory else {
        return [$androidToolchainSdk.error("Cannot find Android SDK in the path. Please refer to https://docs.scade.io/v2.0/docs/installation#configure-sdk for further instructions.")]
      }
      
      let platformsPath = path/"platforms"
      guard platformsPath.exists, platformsPath.isDirectory else {
        return [$androidToolchainSdk.error("Cannot find Android SDK in the path. Please refer to https://docs.scade.io/v2.0/docs/installation#configure-sdk for further instructions.")]
      }
      
      var latestVersion = "android-0"
      for androidPlatformDir in (try? platformsPath.ls()) ?? [] {
        if latestVersion.compare(androidPlatformDir.path.basename(), options: .numeric) == .orderedAscending {
          latestVersion = androidPlatformDir.path.basename()
        }
      }
      
      let targetVersion = "android-24"
      guard  latestVersion.compare(targetVersion, options: .numeric) == .orderedDescending || latestVersion.compare(targetVersion, options: .numeric) == .orderedSame else {
        return [$androidToolchainSdk.error("Android SDK version is \"\(latestVersion)\". Required version is `android-24` or higher.")]
      }
      
      
      return .valid
    }
    
  }
}
