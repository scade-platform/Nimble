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

final class LSPConnector {
  weak var workbench: Workbench?
  
  private var runningServers: [String: [LSPServer]] = [:]
  
  init(_ workbench: Workbench) {
    self.workbench = workbench
    workbench.observers.add(observer: self)
  }
  
  func disconnect() {
    runningServers.forEach {
      $0.1.forEach{$0.stop()}
    }
  }
    
  func createServer(for lang: String) -> LSPServer? {
    guard let server = LSPServerManager.shared.createServer(for: lang),
          let _ = try? server.start() else { return nil }
    
    server.client.connector = self
    return server
  }
  
  func createServer(`in` folder: Folder?, for doc: SourceCodeDocument) -> LSPServer? {
    //Return already running server on the same folder
    if let folderUrl = folder?.path.url, let runningServer = runningServers[doc.languageId]?.first(where: {
      $0.client.workspaceFolders.contains(folderUrl)
    }) {
      return runningServer
    }
    
    guard let server = createServer(for: doc.languageId) else { return nil }
    
    var servers = runningServers[doc.languageId] ?? []
    servers.append(server)
    runningServers[doc.languageId] = servers


    let folderUrls: [URL]
    if let folderUrl = folder?.path.url {
      folderUrls = [folderUrl]
    } else {
      folderUrls = []
    }

    ///TODO: implement support for servers allowing multiple folders for a workspace
    server.client.initialize(workspaceFolders: folderUrls) { [weak self] in
      if server.client.state == .failed {
        self?.runningServers[doc.languageId]?.removeAll{ $0 === server }
      }
    }
    
    return server
  }
  
  
  func findServer(for doc: SourceCodeDocument) -> (LSPServer?, Folder?) {
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
      $0.client.hasOpened(doc: doc)
    }

    return (runningServer, folder)
  }
}


extension LSPConnector: WorkbenchObserver {
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument else { return }
    
    let (runningServer, docFolder) = findServer(for: doc)
            
    if let client = runningServer?.client {
      client.openDocument(doc: doc)
      
    } else if let client = createServer(in: docFolder, for: doc)?.client {
      client.openDocument(doc: doc)
    }
  }
  
  
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument else { return }
    
    let (server, _) = findServer(for: doc)
    
    if let client = server?.client {
      client.closeDocument(doc: doc)
    }
  }
  
  
  func workbenchDidSaveDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument else { return }
    
    let (server, docFolder) = findServer(for: doc)
        
    if let client = server?.client {
      if client.hasOpened(doc: doc) {
        client.saveDocument(doc: doc)
      } else {
        client.openDocument(doc: doc)
      }
    } else if let client = createServer(in: docFolder, for: doc)?.client {
      client.openDocument(doc: doc)
    }
  }

  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) {
    guard let doc = document as? SourceCodeDocument else {
      workbench.statusBar.statusMessage = ""
      return
    }
  }
}
