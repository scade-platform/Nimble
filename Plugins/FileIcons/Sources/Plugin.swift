//
//  Plugin.swift
//  AFileIcon
//
//  Created by Grigory Markin on 15.03.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import NimbleCore

public final class FileIconsModule: Module {
  public static let plugin: Plugin = FileIconsPlugin()
}

final class FileIconsPlugin: Plugin {
  lazy var iconsProvider = FileIconsProvider(iconsPath: self.resources/"Icons")
  
  func load() {
    IconsManager.shared.register(provider: iconsProvider)
  }
}


