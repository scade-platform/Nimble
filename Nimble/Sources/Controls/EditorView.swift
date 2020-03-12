//
//  EditorView.swift
//  Nimble
//
//  Created by Grigory Markin on 06/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

class EditorView: NSViewController {
  lazy var editor: TabbedEditor = {
    return TabbedEditor.loadFromNib()
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()        
  }
  
  func showEditor() {
    guard editor.parent != self else { return }
                          
    addChild(editor)
    view.addSubview(editor.view)
    
    editor.view.frame.size = view.frame.size
  }
  
  func hideEditor() {
    editor.removeFromParent()
    editor.view.removeFromSuperview()
  }
}
