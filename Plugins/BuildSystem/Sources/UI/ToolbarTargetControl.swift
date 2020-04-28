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
    layer.backgroundColor = NSColor.controlColor.cgColor
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
  
    self.leftImage?.isHidden = true
    self.leftLable?.stringValue = "Target..."
    
    self.separatorImage?.imageScaling = .scaleProportionallyDown
    self.separatorImage?.image = separatorTemplate
    self.separatorImage?.isHidden = true
    
    self.rightImage?.isHidden = true
    self.rightLable?.stringValue = ""
  }
  
  private func addMenuItem(target: Target, to menu: NSMenu) {
    let item = NSMenuItem(title: target.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = target
    item.submenu = creatSubmenus(target: target)
    menu.addItem(item)
  }
  
  private func creatSubmenus(target: Target) -> NSMenu? {
    guard !target.variants.isEmpty else {
      return nil
    }
    
    let menu = NSMenu()
    for variant in target.variants {
      let item = NSMenuItem(title: variant.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
      item.target = self
      item.representedObject = (target, variant)
      menu.addItem(item)
    }
    return menu
  }
  
  @IBAction func leftButtonDidClick(_ sender: Any) {
    guard let workbench = self.window?.windowController as? Workbench else {
      return
    }
    //TODO: get list of targets from current workbench
    let targets = [Target]()
    let menu = NSMenu()
    targets.forEach{addMenuItem(target: $0, to: menu)}
//    menu.popUp(positioning: menu.item(at: 0), at: NSEvent.mouseLocation, in: nil)

  }
  
  @IBAction func rightButtonDidClick(_ sender: Any) {
    print("2")
  }
  
  @objc func itemDidSelect(_ sender: Any?) {
    guard let item = sender as? NSMenuItem, let tuple = item.representedObject as? (Target, Variant) else {
      return
    }
//    leftImage?.image = target.icon?.image
    leftLable?.stringValue = tuple.0.name
    
    separatorImage?.isHidden = false
    
    rightLable?.stringValue = tuple.1.name
  }
}
