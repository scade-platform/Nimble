//
//  SwiftToolchain.swift
//  Swift toolchain definition
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



public struct SwiftToolchain: Codable, Equatable {
  public var name: String
  public var compiler: String
  public var compilerFlags: [String]

  public var target: String?
  public var sdkRoot: String?

  public var environment: [String: String]? = nil

  public init(name: String,
              compiler: String,
              compilerFlags: [String],
              target: String? = nil,
              sdkRoot: String? = nil,
              environment: [String: String]? = nil) {
    self.name = name
    self.compiler = compiler
    self.target = target
    self.sdkRoot = sdkRoot
    self.compilerFlags = compilerFlags
    self.environment = environment
  }
}
