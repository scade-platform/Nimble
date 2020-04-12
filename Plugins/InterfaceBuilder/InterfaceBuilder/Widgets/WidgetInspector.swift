//
//  WidgetInspector.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 07.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import ScadeKit

class WidgetInspector: NSViewController, WorkbenchPart {
  
  @IBOutlet weak var stackView: NSStackView?
  
  var icon: NSImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}

extension WidgetInspector : WorkbenchObserver {
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) {
    stackView?.subviews.forEach{$0.removeFromSuperview()}
    if document != nil, let editor = document?.editor as? EditorView  {
      let textPane = TextPane.loadFromNib()
      self.addChild(textPane)
      stackView?.addArrangedSubview(textPane.view)
      textPane.view.trailingAnchor.constraint(equalTo: stackView!.trailingAnchor).isActive = true
      editor.observers.add(observer: textPane)
      textPane.view.isHidden = true
    }
  }
}
