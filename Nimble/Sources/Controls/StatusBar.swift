//
//  StatusBar.swift
//  Nimble
//
//  Created by Danil Kristalev on 13/12/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class StatusBar: NSViewController {
  @IBOutlet weak var leftBarStackView: NSStackView!
  @IBOutlet weak var rightBarStackView: NSStackView!
  
}

extension StatusBar : WorkbenchStatusBar {
  var leftBar: [WorkbenchStatusBarCell] {
    return leftBarStackView.subviews.map{$0 as! WorkbenchStatusBarCell}
  }
  
  var rightBar: [WorkbenchStatusBarCell] {
    return rightBarStackView.subviews.map{$0 as! WorkbenchStatusBarCell}
  }
  
  func addCell(title: String, kind: WorkbenchStatusBarKind) {
    switch kind {
    case .left:
      let textView = NSTextField(labelWithString: title)
      leftBarStackView.addView(textView, in: .trailing)
      break
    case .right:
      let textView = NSTextField(labelWithString: title)
      rightBarStackView.insertView(textView, at: 0, in: .leading)
      break
    }
  }
}

extension NSTextField : WorkbenchStatusBarCell {
  public var title: String {
    get {
      return self.stringValue
    }
    set(newValue) {
      self.stringValue = newValue
    }
  }
  
  
}



