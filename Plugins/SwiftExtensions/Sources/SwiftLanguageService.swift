//
//  SwiftLanguageService.swift
//  SwiftExtensions.plugin
//
//  Created by Grigory Markin on 13.10.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import CodeEditor

/// Swift Language Support not presented by the SourceKit-LSP

final class SwiftLanguageService: LanguageService {
  static let shared = SwiftLanguageService()

  var supportedFeatures: [LanguageServiceFeature] = [.format]

  private init() {}

  func format(doc: SourceCodeDocument) -> Void {
    print("Formatting Swift File")
  }

  func connect(to workbench: Workbench) {

  }

  func disconnect(from workbench: Workbench) {
    
  }
}

