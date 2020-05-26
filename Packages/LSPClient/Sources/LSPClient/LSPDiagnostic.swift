//
//  LSPDiagnostic.swift
//  LSPClient.plugin
//
//  Created by Grigory Markin on 19.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import CodeEditor
import LanguageServerProtocol

struct LSPDiagnostic: SourceCodeDiagnostic {
  let wrapped: LanguageServerProtocol.Diagnostic
    
  var severity: NimbleCore.DiagnosticSeverity {
    guard let severity = wrapped.severity else { return .information }
    switch severity {
    case .error:
      return .error
    case .warning:
      return .warning
    case .hint:
      return .hint
    case .information:
      return .information
    }
  }
  
  var message: String { return wrapped.message }
  
  func range(`in` text: String) -> Range<Int> {
    return text.range(for: text.range(for: wrapped.range))    
  }
}
