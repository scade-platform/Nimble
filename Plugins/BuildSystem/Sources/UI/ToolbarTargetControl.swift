//
//  ToolbarTargetControl.swift
//  Nimble
//
//  Created by Danil Kristalev on 20.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class ToolbarTargetControl : NSControl {
  
  @IBOutlet weak var leftImage: NSImageView?
  @IBOutlet weak var leftLable: NSTextField?
  
  @IBOutlet weak var separatorImage: NSImageView?
  
  @IBOutlet weak var rightParentView: NSView? 
  @IBOutlet weak var rightImage: NSImageView?
  @IBOutlet weak var rightLable: NSTextField?
  
  
  var selectedTarget: Target?
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        leftLable?.textColor = .labelColor
        rightLable?.textColor = .labelColor
      } else {
        leftLable?.textColor = .disabledControlTextColor
        rightLable?.textColor = .disabledControlTextColor
      }
    }
  }
  
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
    layer.backgroundColor = ToolbarTargetControl.controlBackgroundColor.cgColor
    layer.borderColor = ToolbarTargetControl.sharedBorderColor.cgColor
    self.layer = layer
  }
  
  override func layout() {
    if let layer = self.layer {
      //change colors after system theme changed
      layer.borderColor = ToolbarTargetControl.sharedBorderColor.cgColor
      layer.backgroundColor = ToolbarTargetControl.controlBackgroundColor.cgColor
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
  
  private static var controlBackgroundColor: NSColor {
    NSColor(named: "ControlBackgroundColor", bundle: Bundle(for: ToolbarTargetControl.self)) ?? NSColor.controlColor
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  
    self.leftImage?.isHidden = true
    self.leftLable?.stringValue = "Not Targets"
    
    self.separatorImage?.imageScaling = .scaleProportionallyDown
    self.separatorImage?.image = separatorTemplate
    self.separatorImage?.isHidden = true
    
    self.rightParentView?.isHidden = true
    self.rightImage?.isHidden = true
    self.rightLable?.stringValue = ""
  }

  override func viewWillMove(toWindow newWindow: NSWindow?) {
    guard let window = self.window, newWindow == nil else { return }
    selectedVariants.removeValue(forKey: ObjectIdentifier(window))
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
      item.representedObject = variant
      menu.addItem(item)
    }
    return menu
  }
  
  @IBAction func leftButtonDidClick(_ sender: Any) {
    guard let workbench = self.window?.windowController as? Workbench, let buildSystem = BuildSystemsManager.shared.activeBuildSystem else {
      return
    }
    
    let menu = NSMenu()
    if let automatic = buildSystem as? Automatic {
      targets = []
      for automaticTargets in automatic.targetsBySystem(in: workbench) {
        guard !automaticTargets.isEmpty else {
          continue
        }
        automaticTargets.forEach{addMenuItem(target: $0, to: menu)}
        targets.append(contentsOf: automaticTargets)
        menu.addItem(.separator())
      }
    } else {
      targets = buildSystem.targets(in: workbench)
      guard !targets.isEmpty else {
        return
      }
      targets.forEach{addMenuItem(target: $0, to: menu)}
    }
    
    guard !menu.items.isEmpty else {
      return
    }
    menu.popUp(positioning: menu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
  }
  
  @IBAction func rightButtonDidClick(_ sender: Any) {
    guard let workbench = self.window?.windowController as? Workbench, let variant = workbench.selectedVariant, let target = variant.target else {
      return
    }
    if let menu = creatSubmenus(target: target) {
       menu.popUp(positioning: menu.item(at: 0), at: NSEvent.mouseLocation, in: nil)
    }
  }
  
  @objc func itemDidSelect(_ sender: Any?) {
    guard let item = sender as? NSMenuItem else {
      return
    }
    
    let selectedVariant: Variant?
    if let variant = item.representedObject as? Variant {
      leftLable?.stringValue = variant.target?.name ?? ""
      separatorImage?.isHidden = false
      rightLable?.stringValue = variant.name
      selectedVariant = variant
    } else if let target = item.representedObject as? Target {
      leftLable?.stringValue = target.name
      separatorImage?.isHidden = false
      selectedVariant = target.variants.first
      rightLable?.stringValue = selectedVariant?.name ?? ""
    } else {
      selectedVariant = nil
    }
    
    if !(rightLable?.stringValue.isEmpty ?? true) || rightImage != nil {
      rightParentView?.isHidden = false
    }
    
    guard let workbench = self.window?.windowController as? Workbench, let variant = selectedVariant else {
      return
    }
    selectedTarget = variant.target
    workbench.selectedVariant = variant
  }
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else {return true}
    if let target = item.representedObject as? Target {
      item.state = (target.name  == selectedTarget?.name) ? .on : .off
    } 
    return true
  }
}


extension Workbench {
  fileprivate var id: ObjectIdentifier { ObjectIdentifier(self) }

  var selectedVariant: Variant? {
    get {
      if let swiftBuildSystem = BuildSystemsManager.shared.activeBuildSystem as? SwiftBuildSystem {
        let fileTarget =  swiftBuildSystem.targets(in: self)[0]
        targets.append(fileTarget)
        return fileTarget.variants[0]
      }
      return selectedVariants[self.id]
    }
    set {
      selectedVariants[self.id] = newValue

    }
  }
}


fileprivate var selectedVariants: [ObjectIdentifier: Variant] = [:]
fileprivate var targets: [Target] = []
