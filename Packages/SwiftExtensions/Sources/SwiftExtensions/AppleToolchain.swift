//
//  AppleToolchain.swift
//  Contains utility functions for setting up swift flags for Android platfom
//
//  Created by Grigory Markin on 07.04.21.
//

import Foundation

public enum AppleBuildPlatform: String, CaseIterable {
  case macos = "macosx"
  case iphone = "iphoneos"
  case iphonesimulator
}

public struct AppleABI {
  var triple: String
  var sdkRoot: String
}

fileprivate struct ToolchainTuple: Hashable {
  let platform: AppleBuildPlatform
  let compiler: String
}

fileprivate var _toolchains: [ToolchainTuple: SwiftToolchain] = [:]

public func appleToolchainName(for platform: AppleBuildPlatform) -> String {
  return "Apple \(platform.rawValue)"
}

// Makes SwiftToolchain struct for a build target, an apple build platform and a toolchain path
public func makeAppleSwiftToolchain(for platform: AppleBuildPlatform, path: String? = nil) -> SwiftToolchain? {
  var compiler = path ?? Settings.shared.swiftToolchain
  
  if compiler.isEmpty{
    compiler = (try? Process.exec("/usr/bin/xcode-select", arguments: ["--print-path"])) ?? ""
  }

  let tuple = ToolchainTuple(platform: platform, compiler: compiler)

  if let toolchain = _toolchains[tuple] {
    return toolchain
  }

  let props = appleSwiftABI(for: platform)
  return SwiftToolchain(name:  appleToolchainName(for: platform),
                        compiler: compiler,
                        compilerFlags: [
                          "-sdk", props.sdkRoot,
                          "-target", props.triple
                        ])
}


private func appleSwiftABI(for platform: AppleBuildPlatform) -> AppleABI {
  func xcrun(_ cmd: String) -> String {
    return (try? Process.exec("/usr/bin/xcrun",
                              arguments: ["--sdk", platform.rawValue, "--\(cmd)"])) ?? ""
  }

  func abi(with triple: String) -> AppleABI {
    return AppleABI(triple: triple, sdkRoot: xcrun("show-sdk-path"))
  }

  switch platform {
  case .macos:
    return abi(with: "x86_64-apple-macos\(xcrun("show-sdk-version"))")

  case .iphone:
    return abi(with: "arm64-apple-ios\(xcrun("show-sdk-version"))")

  case .iphonesimulator:
    return abi(with: "x86_64-apple-ios\(xcrun("show-sdk-version"))-simulator")
  }
}
