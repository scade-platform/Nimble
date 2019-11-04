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
      
  func applicationDidFinishLaunching(_ aNotification: Notification) {

  }
  
  func applicationWillFinishLaunching(_ notification: Notification) {
    _ = NimbleController()
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    
  }
  
  
}
