//
//  SKLocalServer.swift
//  SwiftExtensions
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
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
import os.log

import LSPClient
import NimbleCore
import BuildSystem


// SourceKitLSP
import SKCore
import SKSupport
import SourceKit
import TSCBasic
import TSCLibc
import TSCUtility
import LSPLogging
import Build
import LanguageServerProtocol


public final class SKLocalServer: LSPServer {
  public enum ServerError: Error {
    case incompatibleVariant
  }

  /// TODO: move to settings
  public static var swiftCompilerFlags: [String] = []
  public static var toolchainSwiftCompilerFlags: [String: [String]] = [:]

  public static func addSwiftCompilerFlags(_ flags: [String], for toolchain: String) {
    var _flags = toolchainSwiftCompilerFlags[toolchain] ?? []
    _flags.append(contentsOf: flags)
    toolchainSwiftCompilerFlags[toolchain] = _flags
  }

  public var isRunning = false

  public var client: LSPClient
  
  private var clientConnection: LocalConnection
  private var serverConnection: LocalConnection
      
  var server: SourceKitServer! = nil
  var toolchain: SwiftToolchain? = nil
  
  init() {
    clientConnection = LocalConnection()
    serverConnection = LocalConnection()
    client = LSPClient(serverConnection)
  }

  public func start(with variant: Variant?) throws {
    let toolchain = (variant as? SwiftVariant)?.toolchain

    print("Using toolchain: \(toolchain?.name)")

    // Setup toolchain (compiler) location
    var installPath: AbsolutePath? = nil
    if let compilerPath = toolchain?.compiler {
      installPath = AbsolutePath(compilerPath)
    }
    ToolchainRegistry.shared = ToolchainRegistry(installPath: installPath, localFileSystem)


    // Setup server options
    var serverOptions = SourceKitServer.Options()
    serverOptions.buildSetup.flags.swiftCompilerFlags.append(contentsOf: SKLocalServer.swiftCompilerFlags)

    if let toolchain = toolchain {
      serverOptions.buildSetup.flags.swiftCompilerFlags += toolchain.compilerFlags

      if let target = toolchain.target {
        serverOptions.buildSetup.triple = try? Triple(target)
      }

      if let sdkRoot = toolchain.sdkRoot {
        serverOptions.buildSetup.sdkRoot = AbsolutePath(sdkRoot)
      }

      if let toolchainFlags = SKLocalServer.toolchainSwiftCompilerFlags[toolchain.name] {
        serverOptions.buildSetup.flags.swiftCompilerFlags.append(contentsOf: toolchainFlags)
      }
    }


    // Create server
    server = SourceKitServer(client: clientConnection, options: serverOptions) { [weak self] in
      self?.stop()
    }
    
    serverConnection.start(handler: server)
    clientConnection.start(handler: client)
        
    Logger.shared.disableNSLog = true
    Logger.shared.disableOSLog = true
    
    Logger.shared.setLogLevel("warning")
    Logger.shared.addLogHandler { [weak self] message, logLevel in
      let messageType: WindowMessageType?

      switch logLevel {
      case .error: messageType = .error
      case .warning: messageType = .warning
      case .info: messageType = .info
      default: messageType = nil
      }

      guard let type = messageType else { return }
      self?.clientConnection.send(LogMessageNotification(type: type, message: message))
    }
    
    isRunning = true
    self.toolchain = toolchain
  }
  
  public func stop() {
    guard isRunning else { return }

    client.prepareForExit()
    server.prepareForExit()
    
    clientConnection.close()
    serverConnection.close()
    
    isRunning = false
  }

  public func shouldRestart(for variant: Variant?) -> Bool {
    guard let toolchain = (variant as? SwiftVariant)?.toolchain else { return false }
    return self.toolchain != toolchain
  }
}


public final class SKLocalServerProvider: LSPServerProvider {
  public var languages = ["swift"]
  
  public init() {}
  
  public func createServer() -> LSPServer {
    return SKLocalServer()
  }
}


//MARK: - Merge BuildFlags

fileprivate extension BuildFlags {
  mutating func append(_ flags: BuildFlags) {
    self.cCompilerFlags.append(contentsOf: flags.cCompilerFlags)
    self.cxxCompilerFlags.append(contentsOf: flags.cxxCompilerFlags)
    self.swiftCompilerFlags.append(contentsOf: flags.swiftCompilerFlags)
    self.linkerFlags.append(contentsOf: flags.linkerFlags)
  }
}


