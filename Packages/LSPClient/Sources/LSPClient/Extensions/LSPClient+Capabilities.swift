//
//  LSPClient+Capabilities.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 06.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

extension LSPClient {
 static let clientCapabilities: ClientCapabilities = {
   var capabilities = ClientCapabilities()
   
   capabilities.workspace = WorkspaceClientCapabilities()
   
   capabilities.workspace?.configuration = true
   capabilities.workspace?.workspaceFolders = true
   
   capabilities.textDocument = TextDocumentClientCapabilities()
   capabilities.textDocument?.publishDiagnostics =
     TextDocumentClientCapabilities.PublishDiagnostics(relatedInformation: true)
   
   
   let completionItemCapabilities = TextDocumentClientCapabilities.Completion.CompletionItem (
     snippetSupport: true,
     commitCharactersSupport: true,
     documentationFormat: [.markdown, .plaintext],
     deprecatedSupport: true,
     preselectSupport: true)
     
   capabilities.textDocument?.completion =
     TextDocumentClientCapabilities.Completion(completionItem: completionItemCapabilities,
                                               contextSupport: true)
   
   capabilities.workspace?.didChangeWatchedFiles = DynamicRegistrationCapability(dynamicRegistration: true)
   capabilities.workspace?.didChangeConfiguration = DynamicRegistrationCapability(dynamicRegistration: true)
   
   return capabilities
 }()  
}
