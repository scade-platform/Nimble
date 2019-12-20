//
//  Diagnostic.swift
//  NimbleCore
//
//  Created by Grigory Markin on 19.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

public enum DiagnosticSeverity {
  case error, warning, information, hint
}

public protocol Diagnostic {
  var severity: DiagnosticSeverity { get }
  var message: String { get }
}
