//
//  WorkbenchViewController.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public class WorkbenchViewController: NSSplitViewController {
  
  public var navigatorViewController: NavigatorViewController? {
    return children[0] as? NavigatorViewController
  }
  
  public var editorViewController: EditorViewController? {
    return children[1] as? EditorViewController
  }
  
}
