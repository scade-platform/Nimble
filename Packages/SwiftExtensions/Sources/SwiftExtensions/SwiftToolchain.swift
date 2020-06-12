//
//  SwiftToolchain.swift
//  Swift toolchain definition
//
//  Created by Alexnader Esilevich on 25.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//


public struct SwiftToolchain: Codable {
    public var name: String
    public var compiler: String
    public var target: String
    public var sdkRoot: String
    public var compilerFlags: [String]

    public init(name: String, compiler: String, target: String, sdkRoot: String, compilerFlags: [String]) {
        self.name = name
        self.compiler = compiler
        self.target = target
        self.sdkRoot = sdkRoot
        self.compilerFlags = compilerFlags
    }
}


public struct SwiftAndroidToolchain: Codable {
    public var compiler: String
    public var sdk: String
    public var ndk: String
}
