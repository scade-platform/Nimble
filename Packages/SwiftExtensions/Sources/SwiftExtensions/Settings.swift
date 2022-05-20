//
//  Settings.swift
//  SwiftExtensions
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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
                     defaultValue: (Path.home/"Library/Android/sdk").string ,
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
    
    let minimalVersion = "5.3.2"
    
    func validateSetting<S: SettingProtocol, T>(_ setting: S) -> [SettingDiagnostic] where S.ValueType == T {
      guard setting == $swiftToolchain else {
        return .valid
      }
      
      if swiftToolchain.isEmpty {
        //Validate XCode version
        guard let pathToXcodeToolchain = Xcode.toolchainDirectory, pathToXcodeToolchain.exists else {
          return [$swiftToolchain.error("Xcode not found.")]
        }
        guard let currentVersion = getVersion(pathToXcodeToolchain) else {
          return [$swiftToolchain.warning("Could not validate Xcode toolchain version.")]
        }
        
        guard isValid(version: currentVersion) else {
          return [$swiftToolchain.error("Swift Toolchain version is \(currentVersion). Swift Toolchain needs to be greater or equal \(minimalVersion).")]
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
        
        guard  isValid(version: currentVersion) else {
          return [$swiftToolchain.error("Swift Toolchain version is \(currentVersion). Swift Toolchain needs to be greater or equal \(minimalVersion).")]
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
      
      let version = parseSwiftVersion(from: versionOutput)
      return version
    }
    
    private func runVersionCommand(_ pathToSwift: Path) -> String? {
      guard let version = try? Process.exec(pathToSwift.string, arguments:  ["--version"]) else {
        return nil
      }
      
      return version
    }
    
    private func parseSwiftVersion(from output: String) -> String? {
      guard isValidSwiftVersionOutput(output) else {
        return nil
      }
      let swiftVersionFirstString = prepareSwiftVersionOutput(output)
      return parseVersion(from: swiftVersionFirstString)
    }
    
    private func isValidSwiftVersionOutput(_ output: String) -> Bool {
      guard let regex = ".*Apple Swift version (\\d+\\.)?(\\d+\\.)?(\\d+).*".asRegex else {
        return false
      }
      return regex.hasMatch(in: output)
    }
    
    private func prepareSwiftVersionOutput(_ output: String) -> String {
      //Since Swift 5.5, the version command displays the swift-driver version first
      //There remove this version
      let substringRange = output.range(of: "Apple Swift version")!
      return String(output[substringRange.lowerBound...])
    }
    
    private func parseVersion(from output: String) -> String? {
      guard let regex = "(\\d+\\.)?(\\d+\\.)?(\\d+)".asRegex else {
        return nil
      }
      
      guard let match = regex.firstMatch(in: output) else {
        return nil
      }
      
      guard let stringRange = Range(match.range, in: output) else {
        return nil
      }
      
      let version = String(output[stringRange])
      return version
    }
    
    private func isValid(version: String) -> Bool {
      //Valid version greater or equal of minimal version
      version.compare(minimalVersion, options: .numeric) == .orderedSame || version.compare(minimalVersion, options: .numeric) == .orderedDescending
    }
  }
  
}
