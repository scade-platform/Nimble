//
//  NavigatorViewController.swift
//  Nimble
//
//  Created by Grigory Markin on 03.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


public class NavigatorView: NimbleSidebarArea {
  public override func viewDidLoad() {
    super.viewDidLoad()
    sidebar?.showButtonsBar = false
  }
}
