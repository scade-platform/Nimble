//
//  Diagnostic.swift
//  NimbleCore
//
//  Created by Grigory Markin on 19.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

public protocol Diagnostic {
  var message: String { get }
  var severity: DiagnosticSeverity { get }
}

public enum DiagnosticSeverity : CaseIterable {
  case error, warning, information, hint
}

public enum DiagnosticSource : Hashable {
  case path(Path)
  case other(String)

  public var string: String {
    switch self {
    case .path(let path):
      return path.string
    case .other(let id):
      return id
    }
  }
}

struct WorkbenchDiagnostic: Diagnostic {
  let message: String
  let severity: DiagnosticSeverity
}
