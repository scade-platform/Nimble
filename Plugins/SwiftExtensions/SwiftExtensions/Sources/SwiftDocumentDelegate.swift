//
//  SwiftCodeCompletion.swift
//  SwiftExtensions
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import CodeEditorCore

import SKCore
import SourceKit
import LanguageServerProtocol


public final class SwiftDocumentDelegate: TextDocumentDelegate {
  private weak var doc: TextDocument?
  
  public init(doc: TextDocument) {
    self.doc = doc
  }
  
  public func complete() -> [String] {
    let rootURL = ProjectManager.shared.currentProject.folders.first!.path.url
    
    var capabilities = ClientCapabilities()
    capabilities.workspace = WorkspaceClientCapabilities()
    capabilities.textDocument = TextDocumentClientCapabilities()
    
    let initRequest = InitializeRequest(rootURL: rootURL, capabilities: capabilities, workspaceFolders: [])
    let response = try? LSP.sendSync(initRequest)
        
    return []
  }
}


fileprivate let client = LocalConnection()
fileprivate let server = SourceKitServer(client: client, buildSetup: BuildSetup.default)

public let LSP: Connection  = {
  client.start(handler: server)
  return client
}()
