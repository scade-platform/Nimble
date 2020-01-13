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
  
  var range: Range<SourceCodePosition> {
    let lb = SourceCodePosition(line: wrapped.range.lowerBound.line,
                                offset: wrapped.range.lowerBound.utf16index)
    
    let ub = SourceCodePosition(line: wrapped.range.upperBound.line,
                                offset: wrapped.range.upperBound.utf16index)
    
    return lb..<ub
  }
  
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
}
