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
  
  @SettingDefinition("swift.toolchain",
                     description: """
                                  Path to the directory with Swift toolchain.
                                  Default value is empy string.
                                  Default value means that will using default toolchain from Xcode.
                                  """,
                     defaultValue: "",
                     validator: SwiftToolchainValidator())
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
    
    let targetVersion = "21.0.0"
    
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
      
      guard  version.compare(targetVersion, options: .numeric) == .orderedDescending ||  version.compare(targetVersion, options: .numeric) == .orderedSame else {
        return [$androidToolchainNdk.warning("Android NDK version is \"\(version)\". Required version is \(targetVersion) or higher.")]
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
    
    let targetVersion = "android-24"
    
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
      
      
      guard  latestVersion.compare(targetVersion, options: .numeric) == .orderedDescending || latestVersion.compare(targetVersion, options: .numeric) == .orderedSame else {
        return [$androidToolchainSdk.error("Android SDK version is \"\(latestVersion)\". Required version is \(targetVersion) or higher.")]
      }
      
      
      return .valid
    }
    
  }
  
  struct SwiftToolchainValidator: SettingValidator {
    @Setting("swift.toolchain")
    private var swiftToolchain: String
    
    let targetVersion = "5.3.2"
    
    func validateSetting<S: SettingProtocol, T>(_ setting: S) -> [SettingDiagnostic] where S.ValueType == T {
      guard setting == $swiftToolchain else {
        return .valid
      }
      
      if swiftToolchain.isEmpty {
        //Validate XCode version
        guard let pathToXcodeToolchain = Path("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain"), pathToXcodeToolchain.exists else {
          return [$swiftToolchain.error("Xcode not found.")]
        }
        guard let currentVersion = getVersion(pathToXcodeToolchain) else {
          return [$swiftToolchain.warning("Could not validate Xcode toolchain version.")]
        }
        
        guard  currentVersion.compare(targetVersion, options: .numeric) == .orderedDescending || currentVersion.compare(targetVersion, options: .numeric) == .orderedSame else {
          return [$swiftToolchain.error("Swift Toolchain version is \(currentVersion). Swift Toolchain needs to be \(targetVersion) or higher.")]
        }
        
        return .valid
        
      } else {
        //Validate user toolchain version
        guard let pathToUserToolchain = Path(swiftToolchain), pathToUserToolchain.exists else {
          return [$swiftToolchain.error("Toolchain not found.")]
        }
        guard let currentVersion = getVersion(pathToUserToolchain) else {
          return [$swiftToolchain.warning("Could not validate toolchain version.")]
        }
        
        guard  currentVersion.compare(targetVersion, options: .numeric) == .orderedDescending || currentVersion.compare(targetVersion, options: .numeric) == .orderedSame else {
          return [$swiftToolchain.error("Swift Toolchain version is \(currentVersion). Swift Toolchain needs to be \(targetVersion) or higher.")]
        }
        
        return .valid
      }
    }
    
    private func getVersion(_ pathToToolchain: Path) -> String? {
      let pathToSwift = pathToToolchain/"usr/bin/swift"
      guard pathToSwift.exists, pathToSwift.isExecutable else {
        return nil
      }
      
      guard let versionOutput = runVersionCommand(pathToSwift) else {
        return nil
      }
      
      guard let versionWordIndex = versionOutput.range(of: "version") else {
        return nil
      }
      
      let version = versionOutput[versionWordIndex.upperBound...versionOutput[versionOutput.index(after: versionWordIndex.upperBound)...].firstIndex(of: " ")!]
      
      
      return String(version.trimmingCharacters(in: CharacterSet(charactersIn: " ")))
    }
    
    private func runVersionCommand(_ pathToSwift: Path) -> String? {
      let proc = Process()
      proc.executableURL = pathToSwift.url
      proc.arguments = ["--version"]
      let out = Pipe()
      proc.standardOutput = out
      do {
        try proc.run()
      } catch {
        return nil
      }
      
      proc.waitUntilExit()

      if proc.terminationReason != .exit || proc.terminationStatus != 0 {
        return nil
      }
      
      let data = out.fileHandleForReading.readDataToEndOfFile()
      guard let str = String(data: data, encoding: .utf8) else {
        return nil
      }
      
      return str
    }
    
  }
  
}
