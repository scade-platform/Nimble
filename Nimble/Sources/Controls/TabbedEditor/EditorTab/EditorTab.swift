//
//  EditorTab.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa

class EditorTab: NSCollectionViewItem {
  @IBOutlet private weak var closeButton: NSButton!
  @IBOutlet private weak var titleLabel: NSTextField!
  @IBOutlet private weak var backgroundView: NSView!
  @IBOutlet private weak var imageView: NSImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }

}
