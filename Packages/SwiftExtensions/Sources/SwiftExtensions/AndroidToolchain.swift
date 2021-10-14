//
//  AndroidToolchain.swift
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

public enum AndroidBuildTarget: String, CaseIterable {
  case x86
  case x86_64
  case arm = "armeabi-v7a"
  case arm64 = "arm64-v8a"
}

private struct AndroidABI {
  var triple: String
  var sysrootArch: String
  var includeArch: String
  var stlArch: String
}

fileprivate struct ToolchainTuple: Hashable {
  let target: AndroidBuildTarget
  let compiler: String
  let ndk: String
}


fileprivate var _toolchains: [ToolchainTuple: SwiftToolchain] = [:]


public func androidToolchainName(for target: AndroidBuildTarget) -> String {
  return "Android \(target.rawValue)"
}

// Makes SwiftToolchain struct for path to compiler, path to NDK, and build target
public func makeAndroidSwiftToolchain(for target: AndroidBuildTarget, compiler: String? = nil, ndk: String? = nil) -> SwiftToolchain? {
  let compiler = compiler ?? Settings.shared.androidSwiftCompiler
  let ndk = ndk ?? Settings.shared.androidToolchainNdk
  guard !compiler.isEmpty, !ndk.isEmpty else {
    return nil
  }

  let tuple = ToolchainTuple(target: target, compiler: compiler, ndk: ndk)

  if let toolchain = _toolchains[tuple] {
    return toolchain
  }

  let props = androidABI(for: target)
  let toolchain = SwiftToolchain(name: androidToolchainName(for: target),
                                 compiler: tuple.compiler,
                                 compilerFlags: [
                                    "-tools-directory",
                                    ndk + "/toolchains/llvm/prebuilt/darwin-x86_64/bin",
                                    "-I",
                                    ndk + "/sysroot/usr/include",
                                    "-I",
                                    ndk + "/sysroot/usr/include/" + props.includeArch,
                                    "-L",
                                    ndk + "/sources/cxx-stl/llvm-libc++/libs/" + props.stlArch,
                                    "-lswiftJNI",
                                    "-lswiftDispatch",
                                    "-ldispatch",
                                    "-lswiftFoundation",
                                    "-lswiftFoundationNetworking"
                                 ],
                                 target: props.triple,
                                 sdkRoot: ndk + "/platforms/android-21/arch-" + props.sysrootArch)

  _toolchains[tuple] = toolchain
  return toolchain
}


private func androidABI(for target: AndroidBuildTarget) -> AndroidABI {
  switch target {
  case .x86_64:
    return AndroidABI(triple: "x86_64-none-linux-android",
                      sysrootArch: "x86_64",
                      includeArch: "x86_64-linux-android",
                      stlArch: "x86_64")
  case .x86:
    return AndroidABI(triple: "i686-none-linux-android",
                      sysrootArch: "x86",
                      includeArch: "i686-linux-android",
                      stlArch: "x86")
  case .arm:
    return AndroidABI(triple: "aarch64-none-linux-android",
                      sysrootArch: "arm64",
                      includeArch: "aarch64-linux-android",
                      stlArch: "arm64-v8a")
  case .arm64:
    return AndroidABI(triple: "armv7-none-linux-androideabi",
                      sysrootArch: "arm",
                      includeArch: "arm-linux-androideabi",
                      stlArch: "armeabi-v7a")
  }
}
