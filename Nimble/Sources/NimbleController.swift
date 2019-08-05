//
//  NimbleController.swift
//  Nimble
//
//  Created by Danil Kristalev on 02/08/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class NimbleController : NSDocumentController {
  
  override init(){
    super.init()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  
  @IBAction func switchProject(_ sender: Any?) {
    let urls = self.urlsFromRunningOpenPanel()
    if let url = urls?.first, let doc = self.currentDocument, let projectDoc = doc as? ProjectDocument {
      try! projectDoc.switchProject(contentsOf: url, ofType: self.defaultType!)
    }
  }
}
