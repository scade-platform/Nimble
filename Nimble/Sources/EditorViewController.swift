//
//  EditorViewController.swift
//  Nimble
//
//  Created by Grigory Markin on 11.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


public class EditorViewController: NSViewController {
  private var tabbedEditor: TabbedEditorController? = nil
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    tabbedEditor = TabbedEditorController.loadFromNib()
    addChild(tabbedEditor!)
    view.addSubview(tabbedEditor!.view)
    tabbedEditor!.view.translatesAutoresizingMaskIntoConstraints = false
    tabbedEditor?.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    tabbedEditor?.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    tabbedEditor?.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    tabbedEditor?.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    tabbedEditor?.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
  }
  
  
  public func showEditor(_ editor: NSViewController, file shownFile: File) {
    tabbedEditor?.addNewTab(viewController: editor, file: shownFile)
  }
}
