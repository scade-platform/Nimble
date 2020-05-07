//
//  SKLocalServer.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//


import Foundation
// SourceKitLSP
import SKCore
import SKSupport
import SourceKit
import TSCBasic
import TSCLibc
import TSCUtility
import LSPLogging
// LSPClient
import LSPClient
import NimbleCore


public extension SKLocalServer {
  @Setting("swift.toolchain", defaultValue: "")
  static var swiftToolchain: String
  
  private static var swiftToolchainInstallPath: AbsolutePath? {
    guard !SKLocalServer.$swiftToolchain.isDefault else { return nil }
    return AbsolutePath(SKLocalServer.swiftToolchain)
  }
}

public final class SKLocalServer: LSPServer {
  public var isRunning = false
  
  public var client: LSPClient
  
  var clientConnection: LocalConnection
  var serverConnection: LocalConnection
      
  var server: SourceKitServer! = nil
  var serverOptions = SourceKitServer.Options()
  
  init() {
    clientConnection = LocalConnection()
    serverConnection = LocalConnection()
    
    client = LSPClient(serverConnection)    
    ToolchainRegistry.shared = ToolchainRegistry(installPath: SKLocalServer.swiftToolchainInstallPath, localFileSystem)
  }
  
  public func start() throws {
    server = SourceKitServer(client: clientConnection, options: serverOptions) { [weak self] in
      self?.stop()
    }
    
    serverConnection.start(handler: server)
    clientConnection.start(handler: client)
        
//    Logger.shared.disableNSLog = true
    Logger.shared.disableOSLog = true
    
//    Logger.shared.setLogLevel("error")
//    Logger.shared.addLogHandler { [weak self] message, _ in
//      self?.clientConnection.send(LogMessageNotification(type: .log, message: message))
//    }
    
    isRunning = true
  }
  
  public func stop() {
    guard isRunning else { return }
    
    server.prepareForExit()
    
    clientConnection.close()
    serverConnection.close()
    
    isRunning = false
  }
}


public final class SKLocalServerProvider: LSPServerProvider {
  public var languages = ["swift"]
  
  public init() {}
  
  public func createServer() -> LSPServer {
    return SKLocalServer()
  }
}
