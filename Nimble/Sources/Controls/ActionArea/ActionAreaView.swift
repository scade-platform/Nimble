//
//  ACtionAreaView.swift
//  Nimble
//
//  Created by Alex Yehorov on 15.08.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

final class ActionAreaBar: NSViewController, WorkbenchViewController {
    
    @IBOutlet weak var button: NSButton!
    
    private var areaImage: NSImage?

    @objc func buttonPressed() {
        actionCallback?()
       }

    var actionCallback: (() -> Void)?

    private func setupView() {
        view.setBackgroundColor(.clear)
        button.target = self
        button.action = #selector(buttonPressed)
        button.imagePosition = .imageOnly
    }
    
    func setup(image: NSImage?) {
        areaImage = image
        button.image = areaImage
    }
    
    func changeState(state: NSControl.StateValue) {
        button.state = state
        switch button.state {
        case .on: button.contentTintColor = .systemBlue
        case .off: button.contentTintColor = .systemGray
        default: ()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

class ActionAreaView: NSView, WorkbenchStatusBarItem {
  override var intrinsicContentSize: NSSize {
    return frame.size
  }
}
