//
//  BinaryFileDocument.swift
//  Nimble
//
//  Created by Danil Kristalev on 17/12/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class BinaryFileDocument : NimbleDocument {
  private lazy var unsupportedPane: UnsupportedPane = {
    let controller = UnsupportedPane.loadFromNib()
    return controller
  }()
    
  override func read(from data: Data, ofType typeName: String) throws {
    return
  }
}


extension BinaryFileDocument : Document {
  static var hierarchyWeight: Int {
    return 0
  }
  
  var editor: WorkbenchEditor? {
    return unsupportedPane
  }
  
  static var typeIdentifiers: [String] {
    //the base uti
    return ["public.item", "public.content"]
  }
  
  static func canOpen(_ file: File) -> Bool {
    return true
  }
}

extension UnsupportedPane : WorkbenchEditor {
  
}
