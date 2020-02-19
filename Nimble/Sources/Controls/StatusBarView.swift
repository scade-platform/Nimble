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
  @IBOutlet weak var editorBarStackView: NSStackView!
  
  var editorBar: [WorkbenchStatusBarItem] {
    get {
      return editorBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem}
    }
    set {
      editorBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach{
        guard let view = $0 as? NSView else { return }
        editorBarStackView.insertView(view, at: 0, in: .leading)
      }
    }
  }
}

extension StatusBarView : WorkbenchStatusBar {
  var leftBar: [WorkbenchStatusBarItem] {
    get {
      return leftBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem}
    }
    set {
      leftBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach{
        guard let view = $0 as? NSView else { return }
        leftBarStackView.addView(view, in: .trailing)
      }
    }
  }
    
  var rightBar: [WorkbenchStatusBarItem] {
    get {
      return rightBarStackView.subviews.compactMap {$0 as? WorkbenchStatusBarItem}
    }
    set {
      rightBarStackView.subviews.forEach{ $0.removeFromSuperview() }
      newValue.forEach{
        guard let view = $0 as? NSView else { return }
        rightBarStackView.insertView(view, at: 0, in: .leading)
      }
    }
  }
}



