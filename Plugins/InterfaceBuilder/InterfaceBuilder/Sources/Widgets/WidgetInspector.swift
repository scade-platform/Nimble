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
      let generalPane = GeneralPane.loadFromNib()
      append(viewController: generalPane)
      editor.observers.add(observer: generalPane)
      
      let textPane = TextPane.loadFromNib()
      append(viewController: textPane)
      editor.observers.add(observer: textPane)
      
    }
  }
  
  func append(viewController: NSViewController) {
    self.addChild(viewController)
    stackView?.addArrangedSubview(viewController.view)
    viewController.view.trailingAnchor.constraint(equalTo: stackView!.trailingAnchor).isActive = true
    viewController.view.isHidden = true
  }
}
