//
//  LSPServer.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 09.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

import NimbleCore

import LanguageServerProtocol
import LanguageServerProtocolJSONRPC


// MARK: - LSPServer

public protocol LSPServer: class {
  var client: LSPClient { get }
  var isRunning: Bool { get }
  
  func start() throws
  func stop()
}


public extension LSPServer {
  var workbench: Workbench? { client.connector?.workbench }
}


// MARK: - LSPServerProvider

public protocol LSPServerProvider {
  var languages: [String] { get }
  func createServer() -> LSPServer
}


// MARK: - LSPServerManager

public final class LSPServerManager {
  static let communicationProtocol: MessageRegistry = {
    let requests: [_RequestType.Type] = []
    let notifications: [NotificationType.Type] = [
      LogMessageNotification.self,
      PublishDiagnosticsNotification.self]
    
    return MessageRegistry(requests: requests, notifications: notifications)
  }()
  
  public static let shared: LSPServerManager = {
    let manager = LSPServerManager()
    if let LSPClientPlugin = PluginManager.shared.plugins["com.scade.nimble.LSPClient"] {
      let providers = LSPClientPlugin.extensions([LSPExternalServerProvider].self,
                                                 at: "languageServers").flatMap{$0}
          
      providers.forEach {
        manager.registerProvider($0)
      }
    }
    return manager
  }()
  
  private init() {}
  
  private var providers: [String: LSPServerProvider] = [:]
  
  private var connectors: [ObjectIdentifier: LSPConnector] = [:]
  
      
  public func connect(to workbench: Workbench) {
    connectors[ObjectIdentifier(workbench)] = LSPConnector(workbench)
  }
  
  public func disconnect(from workbench: Workbench) {
    let key = ObjectIdentifier(workbench)
    connectors[key]?.disconnect()
    connectors.removeValue(forKey: key)
  }
  
  public func registerProvider(_ provider: LSPServerProvider) {
    provider.languages.forEach {
      providers[$0] = provider
    }
  }
  
  public func createServer(for lang: String) -> LSPServer? {
    guard let provider = providers[lang] else { return nil }
    return provider.createServer()
  }
    
}





// MARK: - LSPExternalServer

public final class LSPExternalServer: LSPServer {
  private let proc: Process
  
  private let pipeIn = Pipe()
  private let pipeOut = Pipe()
    
  private var connection: JSONRPCConnection
  
  public var client: LSPClient
  
  public var isRunning: Bool { proc.isRunning }
  

  public init(_ exec: Path, args: [String] = [], env: [String: String]) {
    proc = Process()
    
    proc.executableURL = exec.url
    proc.arguments = args
    proc.environment = env
    
    proc.standardInput = pipeIn
    proc.standardOutput = pipeOut
        
    connection = JSONRPCConnection(protocol: LSPServerManager.communicationProtocol,
                                   inFD: pipeOut.fileHandleForReading.fileDescriptor,
                                   outFD: pipeIn.fileHandleForWriting.fileDescriptor)
        
    client = LSPClient(connection)
    
    proc.terminationHandler = {[weak self] proc in
      self?.connection.close()
    }
  }
  
  public func start() throws {
    try proc.run()
    connection.start(receiveHandler: client)
  }
  
  public func stop() {
    proc.terminate()
  }
}


public struct LSPExternalServerProvider: LSPServerProvider, Decodable {
  let executable: Path
  let arguments: [String]?
  let environment: [String: String]?
  
  public let languages: [String]
  
  public func createServer() -> LSPServer {
    return LSPExternalServer(executable, args: arguments ?? [], env: environment ?? [:])
  }
}
