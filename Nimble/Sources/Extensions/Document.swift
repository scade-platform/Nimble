//
//  Document.swift
//  Nimble
//
//  Created by Grigory Markin on 28.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

extension Document {
  func close() -> Bool {
    var shouldClose = true
    let closeDelegate = DocumentCloseDelegate {shouldClose = $0}
    
    self.canClose(withDelegate: closeDelegate,
                  shouldClose: #selector(DocumentCloseDelegate.document(_:shouldClose:contextInfo:)),
                  contextInfo: nil)
    
    return shouldClose
  }
}

fileprivate class DocumentCloseDelegate: NSObject {
  let shouldClose: (Bool) -> Void
  
  init(_ shouldClose: @escaping (Bool) -> Void) {
    self.shouldClose = shouldClose
  }
  
  @objc func document(_ doc: NSDocument?, shouldClose: Bool, contextInfo: UnsafeRawPointer?) {
    self.shouldClose(shouldClose)
  }
}
