//
//  NimbleConsolePlugin.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public final class NimbleConsole: Module {
  public static var pluginClass: Plugin.Type = NimbleConsolePlugin.self
}

open class NimbleConsolePlugin: Plugin {
  required public init() {
    ConsoleManager.shared.registerControllerClass(NimbleConsoleViewController.self)
  }
  
  static var workbench: Workbench? = nil
  
  public func activate(workbench: Workbench) {
    NimbleConsolePlugin.workbench = workbench
  }
  
  public func deactivate() {
    
  }
}

