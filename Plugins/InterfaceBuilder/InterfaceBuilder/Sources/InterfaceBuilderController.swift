//
//  InterfaceBuilderController.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class InterfaceBuilderController: NSViewController {
  @IBOutlet
  weak var pageView: NSView? = nil
  
  weak var doc: PageDocument? = nil {
    didSet {
      loadPage()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadPage()
  }
  
  private func loadPage() {
    print("Hello World")
  }
}
