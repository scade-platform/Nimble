//
//  AppDelegate.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let documentController = NimbleController()
  var commandsController: CommandsController?
  var iconController: IconController?

  func applicationWillFinishLaunching(_ notification: Notification) {
    commandsController = CommandsController()
    iconController = IconController()
    
    // Register workbench settings
    WorkbenchSettings.register()

    // Loading plugins
    PluginManager.shared.load()
    
    IconsManager.shared.register(provider: iconController!)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    documentController.setupOpenRecentMenu()
  }
}
