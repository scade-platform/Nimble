//
//  ToolbarTargetControl.swift
//  Nimble
//
//  Created by Danil Kristalev on 20.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class ToolbarTargetControl : NSView {
  
  @IBOutlet weak var leftImage: NSImageView?
  @IBOutlet weak var leftLable: NSTextField?
  
  @IBOutlet weak var separatorImage: NSImageView?
  
  @IBOutlet weak var rightImage: NSImageView?
  @IBOutlet weak var rightLable: NSTextField?
  
  private lazy var separatorTemplate: NSImage = {
    let separator = IconsManager.Icons.separator.image
    separator.isTemplate = true
    return separator
  }()
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.wantsLayer = true
    let layer = CALayer()
    layer.masksToBounds = true
    layer.cornerRadius = 5.5
    layer.borderWidth = 0.5
    layer.borderColor = ToolbarTargetControl.sharedBorderColor.cgColor
    self.layer = layer
  }
  
  override func layout() {
    if let layer = self.layer {
      //change border color after system theme changed
      layer.borderColor = ToolbarTargetControl.sharedBorderColor.cgColor
    }
  }
  
  private static var sharedBorderColor: NSColor {
    switch Theme.Style.system {
    case .dark:
      return NSColor(colorCode: "#303030")!
    case .light:
      return NSColor(colorCode: "#B1B1B1")!
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  
    self.leftImage?.image = nil
    self.leftLable?.stringValue = "Target..."
    
    self.separatorImage?.imageScaling = .scaleProportionallyDown
    self.separatorImage?.image = nil
    
    self.rightImage?.image = nil
    self.rightLable?.stringValue = ""
  }
  
  private func addMenuItem(title: String, to menu: NSMenu) {
    let item = NSMenuItem(title: title, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    menu.addItem(item)
  }
  
  @IBAction func leftButtonDidClick(_ sender: Any) {
     print("1")
  }
  
  @IBAction func rightButtonDidClick(_ sender: Any) {
    print("2")
  }
  
  @objc func itemDidSelect(_ sender: Any?) {
    
  }
}
