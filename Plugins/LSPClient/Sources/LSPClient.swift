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
    
    server.send(DidOpenTextDocumentNotification(textDocument: textDocument))
    doc.observers.add(observer: self)
    doc.languageServices.append(self)
  }
  
  
  public func closeDocument(doc: SourceCodeDocument) {
    initializing.wait()
    assert(isInitialized)
    
    guard let url = doc.fileURL else { return }
    let textDocument = TextDocumentIdentifier(url.uri)
    
    server.send(DidCloseTextDocumentNotification(textDocument: textDocument))
    doc.observers.remove(observer: self)
    doc.languageServices.removeAll{$0 === self}
  }
}

// MARK: - MessageHandler

extension LSPClient: MessageHandler {
  public func handle<Notification>(_ notification: Notification, from: ObjectIdentifier) where Notification : NotificationType {
    switch notification {
    case let log as LogMessageNotification:
      print(log.message)
      
    case let diagnostic as PublishDiagnosticsNotification:
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

// MARK: - SourceCodeDocumentObserver

extension LSPClient: SourceCodeDocumentObserver {
  public func textDidChange(document: SourceCodeDocument, range: Range<Int>, text: String) {
    guard let uri = document.fileURL?.uri else { return }
    
    let textDocument = VersionedTextDocumentIdentifier(uri, version: 0)
    
    let length = range.upperBound - range.lowerBound
    let range = document.text.positionRange(for: range).range
        
    let changeEvent = TextDocumentContentChangeEvent(range: range, rangeLength: length, text: text)
    let textChangeEvent = DidChangeTextDocumentNotification(textDocument: textDocument, contentChanges: [changeEvent])
        
    server.send(textChangeEvent)
  }
}


// MARK: - LanguageService

extension LSPClient: LanguageService {
  public func complete(in doc: SourceCodeDocument,
                       at index: String.Index,
                       handler: @escaping (String.Index, [CodeEditor.CompletionItem]) -> Void) {
    
    guard let uri = doc.fileURL?.uri else { return }
    
    let textDocument = TextDocumentIdentifier(uri)
    let position = doc.text.position(at: index).position
            
    let (triggerIndex, triggerKind) = trigger(doc, at: index)        
    
    var request = CompletionRequest(textDocument: textDocument, position: position)
    request.context = CompletionContext(triggerKind: triggerKind)
    
    _ = server.send(request, queue: DispatchQueue.main) {
      guard let items = (try? $0.get())?.items else { return }
      let completions = items.map { CompletionItemWrapper(text: doc.text, item: $0) }
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


// MARK: - CompletionItem

struct CompletionItemWrapper {
  let text: String
  let item: LanguageServerProtocol.CompletionItem
}

struct TextEditWrapper {
  let text: String
  let textEdit: TextEdit
}

extension CompletionItemWrapper: CodeEditor.CompletionItem {
  var label: String {
    return item.label
  }
  
  var detail: String? {
    return item.detail
  }
  
  var documentation: CodeEditor.CompletionItemDocumentation? {
    guard let doc = item.documentation else { return nil }
    switch doc {
    case .string(let val):
      return .plaintext(val)
    case .markupContent(let markup):
      switch markup.kind {
      case .markdown:
        return .markdown(markup.value)
      default:
        return .plaintext(markup.value)
      }
    }
  }
  
  var filterText: String? { item.filterText }
  
  var insertText: String? { item.insertText }
  
  var textEdit: CodeEditor.CompletionTextEdit? {
    guard let textEdit = item.textEdit else { return nil }
    return TextEditWrapper(text: text, textEdit: textEdit)
  }
  
  var kind: CodeEditor.CompletionItemKind {    
    return CodeEditor.CompletionItemKind(rawValue: item.kind.rawValue) ?? .unknown
  }
}

extension TextEditWrapper: CodeEditor.CompletionTextEdit {
  var range: Range<Int> {
    return text.range(for: textEdit.range.range)
  }
  
  var newText: String { textEdit.newText }
}


// MARK: - Transformations

fileprivate extension URL {
  var uri: DocumentURI { return DocumentURI(self) }
}


fileprivate extension SourceCodePosition {
  var position: Position {
    return Position(line: line, utf16index: offset)
  }
}

fileprivate extension Position {
  var position: SourceCodePosition {
    return SourceCodePosition(line: line, offset: utf16index)
  }
}

fileprivate extension Range where Bound == Position {
  var range: Range<SourceCodePosition> {
    return lowerBound.position..<upperBound.position
  }
}

fileprivate extension Range where Bound == SourceCodePosition {
  var range: Range<Position> {
    return lowerBound.position..<upperBound.position
  }
}
