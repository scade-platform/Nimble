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
  enum State {
    case ready, initializing, initialized, failed
  }

  private var initializing = DispatchGroup()

  private var diagnosticPublishers = [Path: DispatchSourceTimer]()

  public weak var connector: LSPConnector? = nil

  private(set) var state: State = .ready

  public private(set) var workspaceFolders: [URL] = []

  public private(set) var openedDocuments: [ObjectIdentifier] = []

  public private(set) var serverCapabilities = ServerCapabilities()


  let connection: Connection

  public init(_ connection: Connection) {
    self.connection = connection
  }
  
  public func initialize(workspaceFolders: [URL], onComplete: (() -> Void)? = nil) {
    // The LSP servers supporting workspace folders, ignore rootURI, hence pass all forlder URLs
    // For the servers without such support only rootURI is used, hence we set
    // the first folder as the root folder per default
    guard state == .ready else { return }

    self.workspaceFolders = workspaceFolders

    var rootURI: DocumentURI? = nil
    if let rootURL = workspaceFolders.first {
      rootURI = DocumentURI(rootURL)
    }
    
    let initRequest = InitializeRequest(rootURI: rootURI,
                                        capabilities: LSPClient.clientCapabilities,
                                        workspaceFolders: workspaceFolders.map {WorkspaceFolder(uri: DocumentURI($0))})
    
    state = .initializing
    initializing.enter()

    _ = connection.send(initRequest, queue: DispatchQueue.main) {[weak self] in
      guard let response = try? $0.get() else {
        self?.state = .failed
        self?.initializing.leave()
        
        onComplete?()
        return
      }

      self?.serverCapabilities = response.capabilities
      
      self?.connection.send(InitializedNotification())
      
      self?.state = .initialized
      self?.initializing.leave()
    }
  }
    
  public func openDocument(doc: SourceCodeDocument) {
    guard let url = doc.fileURL else { return }
    waitInitAndExecute {
      $0.open(url: url, with: doc.text, as: doc.languageId)
      $0.connect(to: doc)
    }
  }
    
  
  public func closeDocument(doc: SourceCodeDocument) {
    guard let url = doc.fileURL else { return }
    waitInitAndExecute {
      $0.close(url: url)
      $0.disconnect(from: doc)
    }
  }
  
  public func saveDocument(doc: SourceCodeDocument) {
    ///TODO: implement
  }
  
  
  public func hasOpened(doc: SourceCodeDocument) -> Bool {
    return openedDocuments.contains{ $0 == ObjectIdentifier(doc) }
  }
  
  private func open(url: URL, with text: String, as lang: String) {
    let textDocument = TextDocumentItem(uri: url.uri,
                                        language: Language(rawValue: lang),
                                        version: 0,
                                        text: text)
    connection.send(DidOpenTextDocumentNotification(textDocument: textDocument))
  }
  
  private func close(url: URL) {
    let textDocument = TextDocumentIdentifier(url.uri)
    connection.send(DidCloseTextDocumentNotification(textDocument: textDocument))
  }
    
  private func connect(to doc: SourceCodeDocument) {
    doc.observers.add(observer: self)
    doc.languageServices.append(self)
    openedDocuments.append(ObjectIdentifier(doc))
  }
  
  private func disconnect(from doc: SourceCodeDocument) {
    doc.observers.remove(observer: self)
    doc.languageServices.removeAll{ $0 === self }
    openedDocuments.removeAll { $0 == ObjectIdentifier(doc) }

//    if let path = doc.path {
//      self.connector?.workbench?.publish(diagnostics: [], for: path)
//    }
  }
  
  private func waitInitAndExecute(_ handler: @escaping (LSPClient) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.initializing.wait()
      DispatchQueue.main.async { [weak self] in
        guard self?.state == .initialized else {return }
        handler(self!)
      }
    }
  }
}



// MARK: - MessageHandler

extension WindowMessageType {
  var severity: NimbleCore.DiagnosticSeverity {
    switch self {
    case .error :
      return .error
    case .warning:
      return .warning
    default:
      return .information
    }
  }
}

extension LSPClient: MessageHandler {
  public func handle<Notification>(_ notification: Notification, from: ObjectIdentifier) where Notification : NotificationType {
    
    switch notification {
    case let log as LogMessageNotification:
      DispatchQueue.main.async {
        self.connector?.workbench?.publish(diagnosticMessage: log.message,
                                           severity: log.type.severity, source: .other("Language Server"))
      }

    case let diagnostic as PublishDiagnosticsNotification:
      DispatchQueue.main.async {
        guard let url = diagnostic.uri.fileURL,
              let path = Path(url: url) else { return }
        
        let diagnostics = diagnostic.diagnostics.map {
          LSPDiagnostic(wrapped: $0)
        }

        self.publish(diagnostics: diagnostics, for: path)
      }
      
    default:
      print("Received: \(type(of: notification).method)")
      return
    }
  }


  public func handle<Request>(_: Request, id: RequestID, from: ObjectIdentifier, reply: @escaping (Result<Request.Response, ResponseError>) -> Void) where Request : RequestType {
    print("Request")
  }


  private func publish(diagnostics: [LSPDiagnostic], for path: Path) {
    if let timer = diagnosticPublishers[path] {
      timer.cancel()
    }

    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline:  .now() + 2.0) // 2 seconds delay
    timer.setEventHandler{[weak self] in
      self?.connector?.workbench?.publish(diagnostics: diagnostics, for: path)
    }
    timer.resume()

    diagnosticPublishers[path] = timer
  }
}

// MARK: - SourceCodeDocumentObserver


extension LSPClient: SourceCodeDocumentObserver {
  public func documentFileDidChange(_ document: Document) {
    ///TODO: implement ???
  }
  
  public func documentFileUrlDidChange(_ document: Document, oldFileUrl: URL?) {
    guard let doc = document as? SourceCodeDocument,
          let url = oldFileUrl else { return }
    
    waitInitAndExecute {
      $0.close(url: url)
      $0.disconnect(from: doc)
    }
  }
  
  public func textDidChange(document: SourceCodeDocument, range: Range<Int>, text: String) {
    guard let uri = document.fileURL?.uri else { return }
    
    let textDocument = VersionedTextDocumentIdentifier(uri, version: 0)
    
    let length = range.upperBound - range.lowerBound
    let range = document.text.positionRange(for: range)
        
    let changeEvent = TextDocumentContentChangeEvent(range: range, rangeLength: length, text: text)
    let textChangeEvent = DidChangeTextDocumentNotification(textDocument: textDocument, contentChanges: [changeEvent])
        
    connection.send(textChangeEvent)
  }
}


// MARK: - LanguageService

extension LSPClient: LanguageService {
  public var supportedFeatures: [LanguageServiceFeature] { [.completion] }

  public func complete(in doc: SourceCodeDocument,
                       at index: String.Index,
                       handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) {
    
    guard let uri = doc.fileURL?.uri else { return }
    
    let textDocument = TextDocumentIdentifier(uri)
    let position = doc.text.position(at: index)
            
    let (triggerIndex, triggerKind) = trigger(doc, at: index)        
    
    var request = CompletionRequest(textDocument: textDocument, position: position)
    request.context = CompletionContext(triggerKind: triggerKind)
    
    _ = connection.send(request, queue: DispatchQueue.main) {
      guard let items = (try? $0.get())?.items else { return }
      let completions = items.map { LSPCompletionItem(item: $0) }
      handler(triggerIndex, completions)
    }
  }
  
  private func trigger(_ doc: SourceCodeDocument, at index: String.Index) -> (String.Index, CompletionTriggerKind) {
//    var stops = [" ", "\n", "\t"]
    let triggerCharacters = serverCapabilities.completionProvider?.triggerCharacters ?? []
        
    var triggerIndex = index
    var triggerKind = CompletionTriggerKind.invoked
    
    while(triggerIndex != doc.text.startIndex) {
      let isTriggered: (String) -> Bool = {
        guard let from = doc.text.index(triggerIndex,
                                        offsetBy: -$0.count,
                                        limitedBy: doc.text.startIndex) else { return false }
        return String(doc.text[from..<triggerIndex]) == $0
      }
      
      let isLetter: () -> Bool = {
        let at = doc.text.index(before: triggerIndex)
        return CharacterSet.letters.contains(doc.text.unicodeScalars[at])
      }
      
      if triggerCharacters.contains(where: isTriggered) {
        triggerKind = .triggerCharacter
        break
//      } else if stops.contains(where: isTriggered) || !isLetter() {
      } else if !isLetter() {
        break
      }
      
      triggerIndex = doc.text.index(before: triggerIndex)
    }
    
   return (triggerIndex, triggerKind)
  }
}


// MARK: - Transformations

fileprivate extension URL {
  var uri: DocumentURI { return DocumentURI(self) }
}
