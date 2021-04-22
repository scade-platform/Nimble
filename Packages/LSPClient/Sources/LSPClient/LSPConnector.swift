//
//  LSPWorkbenchConnector.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 16.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation

import NimbleCore
import CodeEditor
import BuildSystem

public final class LSPConnector {
  public weak var workbench: Workbench?
  
  private var runningServers: [String: [LSPServer]] = [:]
  
  init(_ workbench: Workbench) {
    self.workbench = workbench

    workbench.observers.add(observer: self)
    BuildSystemsManager.shared.observers.add(observer: self)
  }
  
  func disconnect() {
    runningServers.forEach {
      $0.1.forEach{$0.stop()}
    }

    workbench?.observers.remove(observer: self)
    BuildSystemsManager.shared.observers.remove(observer: self)
  }
    
  private func createServer(for lang: String, buildVariant: Variant?) -> LSPServer? {
    guard let server = LSPServerManager.shared.createServer(for: lang) else { return nil }
    server.client.connector = self

    guard let _ = try? server.start(with: buildVariant) else { return nil }

    return server
  }

  private func createServer(for lang: String, in folder: URL?) -> LSPServer? {
    return createServer(for: lang, workspaceFolders: folder != nil ? [folder!] : [])
  }

  private func createServer(for lang: String, workspaceFolders: [URL]) -> LSPServer? {
    guard let server = createServer(for: lang, buildVariant: workbench?.selectedVariant) else { return nil }
    
    var servers = runningServers[lang] ?? []
    servers.append(server)
    runningServers[lang] = servers

    ///TODO: implement support for servers allowing multiple folders for a workspace
    server.client.initialize(workspaceFolders: workspaceFolders) { [weak self] in
      if server.client.state == .failed {
        self?.runningServers[lang]?.removeAll{ $0 === server }
      }
    }

    return server
  }
  
  private func findServer(for doc: SourceCodeDocument) -> (LSPServer?, Folder?) {
    guard let proj = workbench?.project,
          let docUrl = doc.fileURL else { return (nil, nil) }

    let folder: Folder
    if let docFolder = proj.folder(containing: docUrl) {
      folder = docFolder

    } else if let docFolder = Folder(url: docUrl.deletingLastPathComponent()) {
      folder = docFolder

    } else {
      return (nil, nil)
    }

    let runningServer = runningServers[doc.languageId]?.first {
      $0.client.workspaceFolders.contains(folder.path.url)
    }

    return (runningServer, folder)
  }
}


extension LSPConnector: WorkbenchObserver {
  public func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument else { return }
    
    let (runningServer, docFolder) = findServer(for: doc)
            
    if let client = runningServer?.client {
      client.openDocument(doc: doc)
    } else if let client = createServer(for: doc.languageId, in: docFolder?.url)?.client {
      client.openDocument(doc: doc)
    }
  }
  
  
  public func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument else { return }
    
    let (server, _) = findServer(for: doc)
    
    if let client = server?.client {
      client.closeDocument(doc: doc)
    }
  }
  
  
  public func workbenchDidSaveDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument else { return }
    
    let (server, docFolder) = findServer(for: doc)
        
    if let client = server?.client {
      if client.hasOpened(doc: doc) {
        client.saveDocument(doc: doc)
      } else {
        client.openDocument(doc: doc)
      }
    } else if let client = createServer(for: doc.languageId, in: docFolder?.url)?.client {
      client.openDocument(doc: doc)
    }
  }

  public func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) {
    if document == nil {
      workbench.statusBar.statusMessage = ""
    }
  }
}


extension LSPConnector: BuildSystemsObserver {
  public func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?) {
    guard self.workbench === workbench else { return }

//    let langServers = self.runningServers.compactMap {(lang, servers) -> (String, [LSPServer])? in
//      let filteredServers = servers.filter { server in
//        server.client.workspaceFolders.contains { target.contains(url: $0) }
//      }
//
//      return filteredServers.count > 0 ? (lang, filteredServers) : nil
//    }

    for (lang, servers) in self.runningServers {
      servers.forEach { server in
        // Check if the server should be restarted for the provided variant
        guard server.shouldRestart(for: variant) else { return }

        // Store current context
        let workspaceFolders = server.client.workspaceFolders

        // Stop the servers
        server.stop()
        self.runningServers[lang]?.removeAll{ $0 === server }

        // Restart with the previous context
        if let server = self.createServer(for: lang, workspaceFolders: workspaceFolders) {
          workbench.documents.compactMap {$0 as? SourceCodeDocument}.forEach { doc in
            guard let docPath = doc.fileURL?.absoluteString,
                  workspaceFolders.contains(where: {folderUrl in docPath.hasPrefix(folderUrl.absoluteString)}) else { return }

            server.client.openDocument(doc: doc)
          }
        }
      }
    }
  }
}
