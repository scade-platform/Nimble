//
//  LocalServer.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

/*
import Foundation
import LanguageServerProtocol
import LSPLogging
import SKCore
import SKSupport
import SourceKit
import TSCBasic
import TSCLibc
import TSCUtility


final class LocalServer {
  
}

func startLocalServer(_ options: SourceKitServer.Options) -> SourceKitServer {
  let clientConnection = LocalConnection()
  
  let installPath = AbsolutePath(Bundle.main.bundlePath)
  ToolchainRegistry.shared = ToolchainRegistry(installPath: installPath, localFileSystem)

  let server = SourceKitServer(client: clientConnection, options: options, onExit: {
    clientConnection.close()
  })
  
  clientConnection.start(handler: server)

  Logger.shared.addLogHandler { message, _ in
    clientConnection.send(LogMessageNotification(type: .log, message: message))
  }

  return server
}
*/
