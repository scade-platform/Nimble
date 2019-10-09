//
//  HorizontalRootSplitViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 09/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class HorizontalRootSplitViewController: NSSplitViewController {
  
  var workbenchViewController: WorkbenchViewController? {
    return children[0] as? WorkbenchViewController
  }
}
