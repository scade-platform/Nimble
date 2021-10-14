//
//  AppleToolchain.swift
//  Contains utility functions for setting up swift flags for Android platfom
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
