//
//  HorizontalRootSplitViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 09/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class HorizontalRootSplitViewController: NSSplitViewController {
  
  public var editorViewController: EditorViewController? {
    return children[0] as? EditorViewController
  }
  
  public var debugViewController: DebugViewController? {
    return children[1] as? DebugViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let debugViewController = debugViewController else {
      return
    }
    debugViewController.isHidden = true
  }
}
