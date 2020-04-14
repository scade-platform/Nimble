//
//  GeneralPane.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 14.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import ScadeKit

class GeneralPane: NSViewController {
  @IBOutlet weak var visabilityButton: NSButton?
  @IBOutlet weak var headerView: HeaderView?
  
  @IBOutlet weak var contentView: NSView?
  
  override func viewDidLoad() {
     super.viewDidLoad()
     
     visabilityButton?.isHidden = true
     headerView?.button = visabilityButton
   }
  
  @IBAction func buttonDidClick(_ sender: Any) {
    guard let contentView = contentView,
      let visabilityButton = visabilityButton
      else { return }
    
    contentView.isHidden = !contentView.isHidden
    
    visabilityButton.title = contentView.isHidden ? "Show" : "Hide"
    visabilityButton.isHidden = !contentView.isHidden
  }
}

extension GeneralPane: EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget) {
    self.view.isHidden = false
  }
}
