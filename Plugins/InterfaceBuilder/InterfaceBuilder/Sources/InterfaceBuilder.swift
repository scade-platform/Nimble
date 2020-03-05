//
//  InterfaceBuilder.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import Foundation

public final class InterfaceBuilder: Module {
  public static let plugin: Plugin = InterfaceBuilderPlugin()
}

final class InterfaceBuilderPlugin: Plugin {

  func load() {
    DocumentManager.shared.registerDocumentClass(PageDocument.self)
  }
}
