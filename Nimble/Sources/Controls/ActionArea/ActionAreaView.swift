//
//  ACtionAreaView.swift
//  Nimble
//
//  Created by Alex Yehorov on 15.08.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

extension ActionAreaBar: WorkbenchPart {
  var icon: NSImage? { return nil }
}

final class ActionAreaBar: NSViewController, WorkbenchViewController {
    
    @IBOutlet weak var button: NSButton!
    
    private var areaImage: NSImage?

    @objc func buttonPressed() {
        actionCallback?()
//        guard let debugArea = workbench?.debugArea else { return }
//        workbench?.debugArea?.isHidden = !debugArea.isHidden
//
//        guard let selectedColor = NSColor(named: "SelectedSegmentColor", bundle: Bundle.main) else { return }
//
//        button.image = debugArea.isHidden ? areaImage : areaImage?.imageWithTint(selectedColor)
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
