//
//  WorkbenchDiagnosticMock.swift
//  Nimble
//
//  Created by Alex Yehorov on 30.08.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Foundation
import NimbleCore

struct WorkbenchDiagnosticMock: Diagnostic {
  let message: String
  let severity: DiagnosticSeverity
}

