//
//  SwiftLanguageService.swift
//  SwiftExtensions.plugin
//
//  Created by Grigory Markin on 13.10.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation
import CodeEditor

/// Swift Language Support not presented by the SourceKit-LSP

public final class SwiftLanguageService: LanguageService {
  public static let shared = SwiftLanguageService()
  
  //TODO: Remove plugin dependency. Use pacakge.swift file to set up formatter for Swift
  private weak var plugin: Plugin? = nil
  
  private var pluginPath: Path? {
    guard let plugin = plugin else { return nil }
    return Path(url: plugin.bundle.bundleURL)
  }
  
  private var toolPath: Path? {
    guard let pluginPath = pluginPath else {
      return nil
    }
    //From Bundle.module
    let bundleName = "SwiftExtensions_SwiftExtensions.bundle"
    let toolPath = pluginPath/"Contents/Resources/\(bundleName)/Contents/Resources/swift-format"
    return toolPath
  }

  public var supportedFeatures: [LanguageServiceFeature] = [.format]


  private init() {}

  public func format(doc: SourceCodeDocument) -> Void {
    // Bundle.module doesn't work
    guard let path = toolPath, path.exists, path.isExecutable, let docPath = doc.path else {
      return
    }
    
    let proc = Process()
    proc.executableURL = path.url
    proc.arguments = ["format", "\(docPath)"]
    
    let out = Pipe()
    proc.standardOutput = out
    proc.standardError = out
    
    do {
      try proc.run()
    } catch {
      return
    }
    
    proc.waitUntilExit()
    
    let data = out.fileHandleForReading.readDataToEndOfFile()
    guard let str = String(data: data, encoding: .utf8) else {
      return
    }

    if proc.terminationReason != .exit || proc.terminationStatus != 0 {
      doc.editor?.workbench?.publish(diagnosticMessage: "Formater: please fix all errors.", severity: .error, source: .path(doc.path!))
      return
    }
    
    var stream = FormatterOutputStream(doc: doc)
    stream.write(str)
  }

  public func connect(to workbench: Workbench, from plugin: Plugin) {
    workbench.observers.add(observer: self)
    self.plugin = plugin
  }

  public func disconnect(from workbench: Workbench) {
    workbench.observers.remove(observer: self)
    self.plugin = nil
  }
}


extension SwiftLanguageService: WorkbenchObserver {
  public func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument, doc.languageId == "swift" else { return }
    doc.add(service: self)
  }

  public func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    guard let doc = document as? SourceCodeDocument, doc.languageId == "swift" else { return }
    doc.remove(service: self)
  }
}


struct FormatterOutputStream: TextOutputStream {
  var doc: SourceCodeDocument

  mutating func write(_ string: String) {
    doc.replaceText(with: string)
  }
}
