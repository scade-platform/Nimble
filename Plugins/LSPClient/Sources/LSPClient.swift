//
//  LSPClient.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 09.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import NimbleCore
import CodeEditor

import LanguageServerProtocol


public final class LSPClient {
  static let clientCapabilities: ClientCapabilities = {
    var capabilities = ClientCapabilities()
    
    capabilities.workspace = WorkspaceClientCapabilities()
    capabilities.workspace?.workspaceFolders = true
    
    capabilities.textDocument = TextDocumentClientCapabilities()
    capabilities.textDocument?.publishDiagnostics =
      TextDocumentClientCapabilities.PublishDiagnostics(relatedInformation: true)
    
    return capabilities
  }()
  
    
  let server: Connection
  
  weak var connector: LSPWorkbenchConnector? = nil
  
  
  var initializing = DispatchGroup()
  
  
  private(set) var isInitialized: Bool = false
  
  private(set) var serverCapabilities = ServerCapabilities()
  
  
  
  public init(server: Connection) {
    self.server = server
  }
  
  public func initialize(workspaceFolders: [URL]) {
    // The LSP servers supporting workspace folders, ignore rootURI, hence pass all forlder URLs
    // For the servers without such support only rootURI is used, hence we set
    // the first folder as the root folder per default
    guard !isInitialized, let rootURL = workspaceFolders.first else { return }
    let initRequest = InitializeRequest(rootURI: DocumentURI(rootURL),
                                        capabilities: LSPClient.clientCapabilities,
                                        workspaceFolders: workspaceFolders.map{WorkspaceFolder(uri: DocumentURI($0))})
    
    initializing.enter()
    
    _ = server.send(initRequest, queue: DispatchQueue.global(qos: .userInitiated)) {[weak self] in
      guard let response = try? $0.get() else { return }
      
      self?.serverCapabilities = response.capabilities
      self?.server.send(InitializedNotification())
      self?.isInitialized = true
      self?.initializing.leave()
    }
  }
  
  
  public func openDocument(doc: SourceCodeDocument) {
    initializing.wait()
    assert(isInitialized)
    
    guard let url = doc.fileURL else { return }
    let textDocument = TextDocumentItem(uri: url.uri,
                                        language: Language(rawValue: doc.languageId),
                                        version: 0,
                                        text: doc.text)
    
    server.send(DidOpenTextDocument(textDocument: textDocument))
    doc.observers.add(observer: self)
  }
  
  
  public func closeDocument(doc: SourceCodeDocument) {
    initializing.wait()
    assert(isInitialized)
    
    guard let url = doc.fileURL else { return }
    let textDocument = TextDocumentIdentifier(url.uri)
    
    server.send(DidCloseTextDocument(textDocument: textDocument))
    doc.observers.remove(observer: self)
  }
  
}

extension LSPClient: MessageHandler {
  public func handle<Notification>(_ notification: Notification, from: ObjectIdentifier) where Notification : NotificationType {
    switch notification {
    case let log as LogMessage:
      print(log.message)
      
    case let diagnostic as PublishDiagnostics:      
      DispatchQueue.main.async {
        guard let url = diagnostic.uri.fileURL,
              let path = Path(url: url) else { return }
        
        let diagnostics = diagnostic.diagnostics.map {
          LSPDiagnostic(wrapped: $0)
        }
              
        self.connector?.workbench?.publishDiagnostics(for: path, diagnostics: diagnostics)
      }
      
    default:
      print("Received: \(type(of: notification).method)")
      return
    }
  }
  
  public func handle<Request>(_: Request, id: RequestID, from: ObjectIdentifier, reply: @escaping (Result<Request.Response, ResponseError>) -> Void) where Request : RequestType {
    print("Request")
  }
}


extension LSPClient: SourceCodeDocumentObserver {
  public func textDidChange(document: SourceCodeDocument, range: Range<Int>, lengthDelta: Int) {
    /*
    guard let uri = document.fileURL?.uri else { return }
    let textDocument = VersionedTextDocumentIdentifier(uri, version: 0)
            
    //let range = range.lowerBound..<range.upperBound - lengthDelta
    let posRange = document.text.positionRange(for: range)
    let rangeLength = range.upperBound - range.lowerBound
    let text = String(document.text[range])
    
    let lo = posRange.lowerBound.position
    let hi = posRange.upperBound.position
    
    let changeEvent = TextDocumentContentChangeEvent(range: lo..<hi, rangeLength: rangeLength, text: text)
    let textChangeEvent = DidChangeTextDocument(textDocument: textDocument, contentChanges: [changeEvent])
    print("Send")
    server.send(textChangeEvent)
    */
  }
}




extension URL {
  var uri: DocumentURI { return DocumentURI(self) }
}


extension SourceCodePosition {
  var position: Position {
    return Position(line: line, utf16index: offset)
  }
}

