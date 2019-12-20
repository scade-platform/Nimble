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

public protocol LSPServer {
  var client: LSPClient { get }
  var isRunning: Bool { get }
  
  func start() throws
  func stop()
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
      LogMessage.self,
      PublishDiagnostics.self]
    
    return MessageRegistry(requests: requests, notifications: notifications)
  }()
  
  public static let shared: LSPServerManager = {
    let manager = LSPServerManager()
    
    let providers = LSPClientModule.plugin.extensions([LSPExternalServerProvider].self, at: "languageServers").flatMap{$0}
    for provider in providers {
      provider.languages.forEach {
        manager.externalProviders[$0] = provider
      }
    }
    
    return manager
  }()
  
  private init() {}
  
  private var externalProviders: [String: LSPServerProvider] = [:]
  
  private var workbenchConnectors: [ObjectIdentifier: LSPWorkbenchConnector] = [:]
  
      
  func connect(to workbench: Workbench) {
    workbenchConnectors[ObjectIdentifier(workbench)] = LSPWorkbenchConnector(workbench)
  }
  
  func disconnect(from workbench: Workbench) {
    let key = ObjectIdentifier(workbench)
    workbenchConnectors[key]?.disconnect()
    workbenchConnectors.removeValue(forKey: key)
  }

  
  public func createServer(for lang: String) -> LSPServer? {
    guard let provider = externalProviders[lang] else { return nil }
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
        
    client = LSPClient(server: connection)
    
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
