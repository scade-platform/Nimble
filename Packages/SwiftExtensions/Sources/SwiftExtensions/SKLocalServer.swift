//
//  SKLocalServer.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//


import Foundation

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

  @Setting("swift.target", defaultValue: "")
  static var swiftTarget: String

  @Setting("swift.sdkRoot", defaultValue: "")
  static var swiftSdkRoot: String

  @Setting("swift.compilerFlags", defaultValue: [])
  static var swiftCompilerFlags: [String]
  
  private static var swiftToolchainInstallPath: AbsolutePath? {
    guard !SKLocalServer.$swiftToolchain.isDefault else { return nil }
    return AbsolutePath(SKLocalServer.swiftToolchain)
  }

  private static var swiftTargetValue: String? {
    guard !SKLocalServer.$swiftTarget.isDefault else { return nil }
    return SKLocalServer.swiftTarget
  }

  private static var swiftSdkRootValue: AbsolutePath? {
    guard !SKLocalServer.$swiftSdkRoot.isDefault else { return nil }
    return AbsolutePath(SKLocalServer.swiftSdkRoot)
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
    if let targ = SKLocalServer.swiftTargetValue {
      serverOptions.buildSetup.triple = try Triple(targ);
      serverOptions.buildSetup.sdkRoot = SKLocalServer.swiftSdkRootValue

      for flag in SKLocalServer.swiftCompilerFlags {
        serverOptions.buildSetup.flags.swiftCompilerFlags.append(flag)
      }
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
  public func buildVariantDidChange(_ variant: Variant?, in workbench: Workbench) {
    guard self.workbench === workbench else { return }

    print("Build variant is changed")
  }
}
