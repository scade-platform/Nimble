//
//  NSApplication.swift
//  NimbleCore
//
//  Created by Grigory Markin on 17/06/20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

public extension NSApplication {
  var currentWorkbench: Workbench? {
    if let currentDocument = NSDocumentController.shared.currentDocument {
      return currentDocument.windowForSheet?.windowController as? Workbench
    }
    return mainWindow?.windowController as? Workbench
  }
}
