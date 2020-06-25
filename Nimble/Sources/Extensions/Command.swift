//
//  Command.swift
//  Nimble
//
//  Created by Grigory Markin on 19.04.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


extension Command {
  @objc func execute() {    
    guard let workbench = NSApp.currentWorkbench else { return }
    self.run(in: workbench)
  }
}


