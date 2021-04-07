//
//  SKLocalServer.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
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

  public static var buildFlags: BuildFlags = BuildFlags()
  public static var toolchainBuildFlags: [String: BuildFlags] = [:]

  public var isRunning = false

  public var client: LSPClient
  
  private var clientConnection: LocalConnection
  private var serverConnection: LocalConnection
      
  var server: SourceKitServer! = nil
  var currentVariant: SwiftVariant? = nil
  
  init() {
    clientConnection = LocalConnection()
    serverConnection = LocalConnection()
    client = LSPClient(serverConnection)
  }

  public func start(with variant: Variant?) throws {
    currentVariant = variant as? SwiftVariant

    print("Starting using toolchain: \(currentVariant?.toolchain)")

    // Setup toolchain (compiler) location
    var installPath: AbsolutePath? = nil
    if let compilerPath = currentVariant?.toolchain?.compiler {
      installPath = AbsolutePath(compilerPath)
    }
    ToolchainRegistry.shared = ToolchainRegistry(installPath: installPath, localFileSystem)


    // Setup server options
    var buildFlags = SKLocalServer.buildFlags
    var serverOptions = SourceKitServer.Options()

    if let toolchain = currentVariant?.toolchain {
      serverOptions.buildSetup.flags.swiftCompilerFlags += toolchain.compilerFlags

      if let target = toolchain.target {
        serverOptions.buildSetup.triple = try? Triple(target)
      }

      if let sdkRoot = toolchain.sdkRoot {
        serverOptions.buildSetup.sdkRoot = AbsolutePath(sdkRoot)
      }

      if let toolchainFlags = SKLocalServer.toolchainBuildFlags[toolchain.name] {
        buildFlags.append(toolchainFlags)
      }
    }

    serverOptions.buildSetup.flags.append(buildFlags)


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
    guard let variant = variant as? SwiftVariant else { return false }
    return variant.toolchain != currentVariant?.toolchain
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


