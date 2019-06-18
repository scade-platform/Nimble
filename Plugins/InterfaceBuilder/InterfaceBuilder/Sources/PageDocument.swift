//
//  PageDocument.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore


public final class PageDocument: NSDocument, Document {
  // private var page: SCDWidgetsPage = SCDWidgetsPage()
  
  private lazy var builderController: InterfaceBuilderController = {
    let controller = InterfaceBuilderController.loadFromNib()
    controller.doc = self
    return controller
  }()
  
  public var contentViewController: NSViewController? { return builderController }
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    // Read data
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}
