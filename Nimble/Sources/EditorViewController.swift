//
//  EditorViewController.swift
//  Nimble
//
//  Created by Grigory Markin on 11.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public class EditorViewController: NSViewController {
  private weak var currentEditor: NSViewController? = nil
  
  public func showEditor(_ editor: NSViewController) {
    currentEditor?.view.removeFromSuperview()
    currentEditor?.removeFromParent()
    currentEditor = editor
    
    editor.view.frame = view.frame
    
    addChild(editor)
    view.addSubview(editor.view)
  }
}
