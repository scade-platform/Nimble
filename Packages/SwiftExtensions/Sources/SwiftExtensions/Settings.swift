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
                     defaultValue: "")
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
      guard  version.compare(targetVersion, options: .numeric) == .orderedDescending else {
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
}
