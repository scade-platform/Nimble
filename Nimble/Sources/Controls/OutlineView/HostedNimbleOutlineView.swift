//
//  HostedNimbleOutlineView.swift
//  Nimble
//
//  Created by Alex Yehorov on 05.10.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import SwiftUI

@available(macOS 11.0, *)
class HostedNimbleOutlineView: NSViewController, WorkbenchViewController {
  
  override func loadView() {
     self.view = NSView()
   }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let myView = NSHostingView(rootView: NimbleOutlineSwiftUIView())
    myView.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(myView)

    NSLayoutConstraint.activate([
      myView.topAnchor.constraint(equalTo: view.topAnchor),
      myView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      myView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      myView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

@available(macOS 11.0, *)
extension HostedNimbleOutlineView: WorkbenchPart {
  var icon: NSImage? { return nil }
}
