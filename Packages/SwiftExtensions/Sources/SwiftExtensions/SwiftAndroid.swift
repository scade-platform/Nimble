//
//  File.swift
//  Contains utility functions for setting up swift flags for Android platfom
//
//  Created by Alexander on 02.09.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import Foundation


public enum AndroidBuildTarget: String, CaseIterable {
  case ARM = "armeabi-v7a"
  case ARM64 = "arm64-v8a"
  case X86 = "x86"
  case X86_64 = "x86_64"
}

private struct AndroidABI {
  var triple: String
  var sysrootArch: String
  var includeArch: String
  var stlArch: String
}


private let androidABIs: [AndroidBuildTarget: AndroidABI] = [
  .X86_64: AndroidABI(triple: "x86_64-none-linux-android",
                        sysrootArch: "x86_64",
                        includeArch: "x86_64-linux-android",
                        stlArch: "x86_64"),
  .X86: AndroidABI(triple: "i686-none-linux-android",
                    sysrootArch: "x86",
                    includeArch: "i686-linux-android",
                    stlArch: "x86"),
  .ARM: AndroidABI(triple: "aarch64-none-linux-android",
                    sysrootArch: "arm64",
                    includeArch: "aarch64-linux-android",
                    stlArch: "arm64-v8a"),
  .ARM64: AndroidABI(triple: "armv7-none-linux-androideabi",
                      sysrootArch: "arm",
                      includeArch: "arm-linux-androideabi",
                      stlArch: "armeabi-v7a")
]


// Makes SwiftToolchain struct for path to compiler, path to NDK, and build target
public func makeAndroidSwiftToolchain(compiler: String,
                                      ndk: String,
                                      target: AndroidBuildTarget) -> SwiftToolchain {
  let props = androidABIs[target]!;
  return SwiftToolchain(
    name: "Android " + target.rawValue,
    compiler: compiler,
    target: props.triple,
    sdkRoot: ndk + "/platforms/android-21/arch-" + props.sysrootArch,
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
    ]
  )
}
