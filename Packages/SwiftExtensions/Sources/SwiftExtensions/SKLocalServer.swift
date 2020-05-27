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


public extension SKLocalServer {
  @Setting("swift.toolchain", defaultValue: "")
  static var swiftToolchain: String
}

public final class SKLocalServer: LSPServer {
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

  private func resetConnection() {
    clientConnection = LocalConnection()
    serverConnection = LocalConnection()
    client = LSPClient(serverConnection)
  }
  
  public func start() throws {
    currentVariant = client.connector?.workbench?.selectedVariant as? SwiftVariant
    var serverOptions = SourceKitServer.Options()

    if let toolchain = currentVariant?.getToolchain() {
      let compilerPath = AbsolutePath(toolchain.compiler)
      ToolchainRegistry.shared = ToolchainRegistry(installPath: compilerPath, localFileSystem)
      serverOptions.buildSetup.triple = try Triple(toolchain.target);
      serverOptions.buildSetup.sdkRoot = AbsolutePath(toolchain.sdkRoot)
      serverOptions.buildSetup.flags.swiftCompilerFlags += toolchain.compilerFlags
    } else {
      ToolchainRegistry.shared = ToolchainRegistry(installPath: nil, localFileSystem)
    }

    server = SourceKitServer(client: clientConnection, options: serverOptions) { [weak self] in
      self?.stop()
    }
    
    serverConnection.start(handler: server)
    clientConnection.start(handler: client)
        
//    Logger.shared.disableNSLog = true
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
    BuildSystemsManager.shared.observers.add(observer: self)
  }
  
  public func stop() {
    guard isRunning else { return }
    
    server.prepareForExit()
    
    clientConnection.close()
    serverConnection.close()
    
    isRunning = false
    BuildSystemsManager.shared.observers.remove(observer: self)
  }
}


public final class SKLocalServerProvider: LSPServerProvider {
  public var languages = ["swift"]
  
  public init() {}
  
  public func createServer() -> LSPServer {
    return SKLocalServer()
  }
}



extension SKLocalServer: BuildSystemsObserver {
  public func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?) {
    guard self.workbench === workbench,
          let target = variant?.target,
          // Ensure there is at least one workspace folder included into the target
          client.workspaceFolders.contains(where: { target.contains(url: $0) }) else { return }

    // don't restart server if variant is not a swift variant
    guard let sVariant = variant as? SwiftVariant else { return }

    if currentVariant == nil {
      // don't restart server if current variant is not yet set. Nimble sets
      // variant after server start
      currentVariant = sVariant
      return
    }

    stop()
    resetConnection()

    do {
      try start()
    }
    catch {
      os_log("can't start SourceKit server", type: .error)
    }
  }
}
