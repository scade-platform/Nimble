//
//  FileTableCellView.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 27/08/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class FileTableCellView : NSTableCellView {
  @IBOutlet weak var closeButton : NSButton!
  var closeDocumentCallback: ((Document) -> Void)?
  
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    closeButton.target = self
    closeButton.action = #selector(closeFile(_:))
  }
  
  @objc func closeFile(_ sender: Any) {
    guard let document = self.objectValue as? Document else {
      return
    }
    closeDocumentCallback?(document)
  }
  
}
