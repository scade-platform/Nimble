//
//  Settings.swift
//  
//
//  Created by Grigory Markin on 07.04.21.
//

import Foundation
import NimbleCore

public struct Settings {
  @Setting("swift.toolchain", defaultValue: "")
  public static var swiftToolchain: String

  @Setting("swift.platforms", defaultValue: [])
  public static var platforms: [SwiftToolchain]

  @Setting("com.android.toolchain.swift", defaultValue: nil)
  public static var androidSwiftCompiler: String?

  @Setting("com.android.toolchain.sdk", defaultValue: nil)
  public static var androidToolchainSdk: String?

  @Setting("com.android.toolchain.ndk", defaultValue: nil)
  public static var androidToolchainNdk: String?

  public static func register() {
    NimbleCore.Settings.shared.add($swiftToolchain)
    NimbleCore.Settings.shared.add($platforms)
    NimbleCore.Settings.shared.add($androidSwiftCompiler)
    NimbleCore.Settings.shared.add($androidToolchainSdk)
    NimbleCore.Settings.shared.add($androidToolchainNdk)
  }
}
