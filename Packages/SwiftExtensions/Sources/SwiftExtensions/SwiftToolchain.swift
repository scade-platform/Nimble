//
//  SwiftToolchain.swift
//  Swift toolchain definition
//
//  Created by Alexnader Esilevich on 25.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//


public struct SwiftToolchain: Codable, Equatable {
  public var name: String
  public var compiler: String
  public var compilerFlags: [String]

  public var target: String?
  public var sdkRoot: String?

  public init(name: String, compiler: String, compilerFlags: [String], target: String? = nil, sdkRoot: String? = nil) {
    self.name = name
    self.compiler = compiler
    self.target = target
    self.sdkRoot = sdkRoot
    self.compilerFlags = compilerFlags
  }
}
