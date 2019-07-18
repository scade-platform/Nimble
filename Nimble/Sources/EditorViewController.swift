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
        tabbedEditor!.view.frame = view.frame
    }
    
    
    public func showEditor(_ editor: NSViewController, file shownFile: File) {
        tabbedEditor?.addNewTab(viewController: editor, file: shownFile)
    }
}
