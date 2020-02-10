//
//  StatusBarView.swift
//  Nimble
//
//  Created by Danil Kristalev on 13/12/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class StatusBarView: NSViewController {
  @IBOutlet weak var leftBarStackView: NSStackView!
  @IBOutlet weak var rightBarStackView: NSStackView!

  
}

extension StatusBarView : WorkbenchStatusBar {
  
  var leftBar: [WorkbenchStatusBarCell] {
    get {
      return leftBarStackView.subviews.map{$0 as! WorkbenchStatusBarCell}
    }
    set {
      leftBarStackView.subviews.removeAll()
      for value in newValue {
        let textView = NSTextField(labelWithString: value.title)
        if let colorableValue = value as? Colorable {
          textView.textColor = colorableValue.color
        }
        leftBarStackView.addView(textView, in: .trailing)
      }
    }
  }
  
  var rightBar: [WorkbenchStatusBarCell] {
    get {
      return rightBarStackView.subviews.map{$0 as! WorkbenchStatusBarCell}
    }
    set {
      rightBarStackView.subviews.removeAll()
      for value in newValue {
        let textView = NSTextField(labelWithString: value.title)
        if let colorableValue = value as? Colorable {
          textView.textColor = colorableValue.color
        }
        rightBarStackView.insertView(textView, at: 0, in: .leading)
      }
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

extension NSTextField : Colorable {
  public var color: NSColor {
    get {
      return self.textColor!
    }
    set(newValue) {
      self.textColor = newValue
    }
  }
}



