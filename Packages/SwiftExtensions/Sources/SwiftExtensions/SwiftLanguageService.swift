//
//  SwiftLanguageService.swift
//  SwiftExtensions.plugin
//
//  Created by Grigory Markin on 13.10.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import CodeEditor
import SwiftFormat
import SwiftFormatConfiguration

/// Swift Language Support not presented by the SourceKit-LSP

public final class SwiftLanguageService: LanguageService {
  public static let shared = SwiftLanguageService()

  public var supportedFeatures: [LanguageServiceFeature] = [.format]

  private lazy var formatter: SwiftFormatter = {
    /// TODO: configuration loading
    return SwiftFormatter(configuration: Configuration())
  }()

  private init() {}

  public func format(doc: SourceCodeDocument) -> Void {
    var stream = FormatterOutputStream(doc: doc)
    try? formatter.format(source: doc.text, assumingFileURL: doc.fileURL, to: &stream)
  }

  public func connect(to workbench: Workbench) {
    workbench.observers.add(observer: self)
  }

  public func disconnect(from workbench: Workbench) {
    workbench.observers.remove(observer: self)
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
