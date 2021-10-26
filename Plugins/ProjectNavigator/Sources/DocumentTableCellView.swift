//
//  FileTableCellView.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 27/08/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class DocumentTableCellView : NSTableCellView {
  @IBOutlet weak var closeButton : NSButton!
  var onCloseDocument: ((Document) -> Void)?
  
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    closeButton.target = self
    closeButton.action = #selector(closeDocument(_:))
  }
  
  @objc func closeDocument(_ sender: Any) {
    guard let doc = self.objectValue as? Document else {
      return
    }
    onCloseDocument?(doc)
  }
  
}
