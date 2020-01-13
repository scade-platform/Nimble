//
//  LSPWorkbenchConnector.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 16.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import CodeEditor

final class LSPWorkbenchConnector {
  weak var workbench: Workbench?
  private var runningServers: [String: LSPServer] = [:]
  
  init(_ workbench: Workbench) {
    self.workbench = workbench
    workbench.observers.add(observer: self)
  }
  
  func disconnect() {
    runningServers.forEach {
      $0.1.stop()
    }
  }
  
  func getServer(for lang: String) -> LSPServer? {
    if let server = runningServers[lang] {
      return server
    }
    let server = LSPServerManager.shared.createServer(for: lang)
    runningServers[lang] = server
    return server
  }
  
  func getClient(for lang: String, run: Bool = true) -> LSPClient? {
    guard let server = getServer(for: lang) else { return nil }
    
    if run && !server.isRunning {
      guard let _ = try? server.start() else { return nil }
    }
    
    server.client.connector = self
    return server.client
  }
}


extension LSPWorkbenchConnector: WorkbenchObserver {
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument,
          let client = getClient(for: doc.languageId) else { return }
    
    if !client.isInitialized, let project = workbench.project {
      client.initialize(workspaceFolders: project.folders.map{$0.url})
    }
    
    client.openDocument(doc: doc)
  }
  
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument,
          let client = getClient(for: doc.languageId) else { return }
    
    client.closeDocument(doc: doc)
  }
  
}
