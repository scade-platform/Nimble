//
//  LSPClient+Capabilities.swift
//  LSPClient.plugin
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

import LanguageServerProtocol

extension LSPClient {
 static let clientCapabilities: ClientCapabilities = {
   var capabilities = ClientCapabilities()
   
   capabilities.workspace = WorkspaceClientCapabilities()
   
   capabilities.workspace?.configuration = true
   capabilities.workspace?.workspaceFolders = true
   
   capabilities.textDocument = TextDocumentClientCapabilities()
   capabilities.textDocument?.publishDiagnostics =
     TextDocumentClientCapabilities.PublishDiagnostics(relatedInformation: true,
                                                       codeActionsInline: true)
   
   
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
