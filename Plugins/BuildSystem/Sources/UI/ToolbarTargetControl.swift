//
//  ToolbarTargetControl.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa
import NimbleCore
import BuildSystem
import os.log

class ToolbarTargetControl : NSControl, CommandControl {
  fileprivate struct VariantsGroupMenuItem {
    let title: String
  }

  @IBOutlet weak var leftParentView: NSView?
  @IBOutlet weak var leftImage: NSImageView?
  @IBOutlet weak var leftLable: NSTextField?
  
  @IBOutlet weak var separatorImage: NSImageView?
  
  @IBOutlet weak var rightParentView: NSView?
  @IBOutlet weak var rightImage: NSImageView?
  @IBOutlet weak var rightLable: NSTextField?

  private weak var borderLayer: CALayer?
  private var trackingArea: NSTrackingArea? = nil
  weak var workbench: Workbench?
  

  private var targetsMenu: NSMenu? {
    didSet {
      //If targetsMenu is empty or nil clear control
      guard let menu = targetsMenu else {
        clear()
        return
      }
      
      guard !menu.items.isEmpty else {
        clear()
        return
      }
    
    }
  }
  private var variantsMenu: NSMenu?

  private weak var _activeVariant: Variant?
  var activeVariant: Variant? {
    get { _activeVariant }
    set {
      if let newValue = newValue, newValue !== _activeVariant {
        select(variant: newValue)
      }

      if newValue?.target !== activeTarget {
        variantsMenu = createVariantsMenu(newValue)
      }

      _activeVariant = newValue
    }
  }

  var activeTarget: Target? {
    activeVariant?.target
  }

  override var isEnabled: Bool {
    didSet {
      let textColor: NSColor = isEnabled ? .labelColor : .disabledControlTextColor
      leftLable?.textColor = textColor
      rightLable?.textColor = textColor
    }
  }
  
  private lazy var separatorTemplate: NSImage = {
    let separator = IconsManager.Icons.separator.image
    separator.isTemplate = true
    return separator
  }()
  
  lazy var topBackgroundColor : NSColor = {
    NSColor(named: "TopGradientColor", bundle: Bundle(for: ToolbarTargetControl.self)) ?? NSColor.controlColor
  }()
  
  lazy var bottomBackgroundColor : NSColor = {
    NSColor(named: "BottomGradientColor", bundle: Bundle(for: ToolbarTargetControl.self)) ?? NSColor.controlColor
  }()
  
  lazy var topBorderColor : NSColor = {
    NSColor(named: "TopBorderGradientColor", bundle: Bundle(for: ToolbarTargetControl.self)) ?? ToolbarTargetControl.sharedBorderColor
  }()
  
  lazy var bottomBorderColor : NSColor = {
    NSColor(named: "BottomBorderGradientColor", bundle: Bundle(for: ToolbarTargetControl.self)) ?? ToolbarTargetControl.sharedBorderColor
  }()
  
  private var highlightColor: NSColor {
    //TODO: Use assert color
    if self.effectiveAppearance.name == .vibrantLight {
      return NSColor(srgbRed: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    } else {
      return NSColor(srgbRed: 0.192, green: 0.176, blue: 0.192, alpha: 1)
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setupVisuals()
  }
  
  override func layout() {
    if #available(macOS 11, *) {
      //Do nothing
    } else {
      if let layer = self.layer as? CAGradientLayer {
        //change colors after system theme changed
        layer.colors = [self.bottomBackgroundColor.cgColor, self.topBackgroundColor.cgColor]
        addGradienBorder(colors: [self.bottomBorderColor, self.topBorderColor])
      }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    self.separatorImage?.imageScaling = .scaleProportionallyDown
    self.separatorImage?.image = separatorTemplate

    clear()
  }

  override func viewWillMove(toWindow newWindow: NSWindow?) {
    guard newWindow != nil else {
      BuildSystemsManager.shared.observers.remove(observer: self)
      return
    }
    
    BuildSystemsManager.shared.observers.add(observer: self)
  }


  private func setupVisuals() {
    if #available(macOS 11, *) {
      let layer = CALayer()
      layer.masksToBounds = true
      layer.cornerRadius = 4.5
      layer.backgroundColor = .clear
      self.wantsLayer = true
      self.layer = layer
    } else {
      let layer = CAGradientLayer()
      layer.masksToBounds = true
      layer.cornerRadius = 4.5
      layer.colors = [self.bottomBackgroundColor.cgColor,
                      self.topBackgroundColor.cgColor]

      self.wantsLayer = true
      self.layer = layer

      addGradienBorder(colors: [self.bottomBorderColor, self.topBorderColor])
    }
  }
  
  override func updateTrackingAreas() {
    guard #available(macOS 11, *) else {
      super.updateTrackingAreas()
      return
    }
    
    if let ta = trackingArea {
      self.removeTrackingArea(ta)
    }

    let opts: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
    trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self)

    self.addTrackingArea(trackingArea!)
  }
  
  override func mouseEntered(with theEvent: NSEvent) {
    guard self.isEnabled else { return }
    let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
    colourAnim.fromValue = self.layer?.backgroundColor
    colourAnim.toValue = NSColor.controlBackgroundColor.cgColor
    colourAnim.duration = 1.0
    colourAnim.fillMode = .forwards
    colourAnim.isRemovedOnCompletion = false
    self.layer?.add(colourAnim, forKey: "backgroundColor")
    self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
  }
  
  override func mouseExited(with event: NSEvent) {
    guard self.isEnabled else { return }
    self.layer?.backgroundColor = .clear
  }

  private func addGradienBorder(colors:[NSColor], width:CGFloat = 1) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame =  CGRect(origin: .zero, size: self.bounds.size)
    gradientLayer.colors = colors.map({$0.cgColor})
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.lineWidth = width
    shapeLayer.path = NSBezierPath(roundedRect: self.bounds, xRadius: 4.5, yRadius: 4.5).cgPath
    shapeLayer.fillColor = nil
    shapeLayer.strokeColor = NSColor.black.cgColor
    gradientLayer.mask = shapeLayer
    
    if let borderLayer = borderLayer {
      self.layer?.replaceSublayer(borderLayer, with: gradientLayer)
      self.borderLayer = gradientLayer
    } else {
      self.layer?.addSublayer(gradientLayer)
      self.borderLayer = gradientLayer
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
    NSColor(named: "ControlBackgroundColor",
            bundle: Bundle(for: ToolbarTargetControl.self)) ?? NSColor.controlColor
  }


  private func clear() {
    self.leftImage?.isHidden = true
    self.leftLable?.stringValue = "No Targets"

    self.separatorImage?.isHidden = true

    self.rightParentView?.isHidden = true
    self.rightImage?.isHidden = true
    self.rightLable?.stringValue = ""
  }

  private func createTargetsMenu() -> NSMenu? {
    guard let workbench = self.workbench else { return nil }
    let menu = NSMenu()

    for (name, items) in BuildSystemsManager.shared.rootTargets(workbench: workbench) {
      guard items.count > 1 else {
        // don't add submenu with build system name if entry has single item
        menu.addItem(createMenuItem(targetItem: items.first!))
        continue
      }

      let targetItem = NSMenuItem(title: name,
                                  action: #selector(itemDidSelect(_:)), keyEquivalent: "")
      targetItem.target = self
      targetItem.representedObject = name
      targetItem.image = IconsManager.icon(systemSymbolName: "square.on.square").image

      let bsSubmenu = NSMenu()
      for item in items {
        let bsItem = createMenuItem(targetItem: item)
        bsItem.title = item.buildSystem.name
        bsItem.target = self
        bsItem.representedObject = item

        bsSubmenu.addItem(bsItem)
      }

      targetItem.submenu = bsSubmenu
      menu.addItem(targetItem)
    }

    guard !menu.items.isEmpty else { return nil }
    return menu
  }

  private func createVariantsMenu(_ variant: Variant?) -> NSMenu? {
    guard let variant = variant else { return nil }

    let target = variant.target
    let menu = createSubmenu(variantGroup: target.variants)
    menu.delegate = self
    return menu
  }

  // Creates menu item for variant
  private func createMenuItem(variant: Variant) -> NSMenuItem {
    let item = NSMenuItem(title: variant.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = variant
    item.image = variant.icon?.image
    return item
  }

  // Creates menu item for variant group
  private func createMenuItem(variantGroup: VariantGroup) -> NSMenuItem {
    let item = NSMenuItem(title: variantGroup.name, action: nil, keyEquivalent: "")
    item.target = self
    item.representedObject = variantGroup
    item.image = variantGroup.icon?.image
    item.submenu = createSubmenu(variantGroup: variantGroup)
    return item
  }

  // Creates submenu for variant group
  private func createSubmenu(variantGroup: VariantGroup) -> NSMenu {
    let menu = NSMenu()
    for item in variantGroup.items {
      menu.items.append(createMenuItem(variantItem: item))
    }

    return menu
  }

  // Creates menu item for variant tree item
  private func createMenuItem(variantItem: VariantTreeItem) -> NSMenuItem {
    if let _ = variantItem as? VariantSeparator {
      return .separator()
    } else if let variant = variantItem as? Variant {
      return createMenuItem(variant: variant)
    } else if let group = variantItem as? VariantGroup {
      return createMenuItem(variantGroup: group)
    } else {
      fatalError("Unknown variant tree item type")
    }
  }

  // Creates menu item for target
  private func createMenuItem(target: Target) -> NSMenuItem {
    let item = NSMenuItem(title: target.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = target
    item.image = target.icon?.image
    item.submenu = createSubmenu(variantGroup: target.variants)
    return item
  }

  // Creates menu item for target group
  private func createMenuItem(targetGroup: TargetGroup) -> NSMenuItem {
    let item = NSMenuItem(title: targetGroup.name, action: nil, keyEquivalent: "")
    item.target = self
    item.representedObject = targetGroup
    item.image = targetGroup.icon?.image
    item.submenu = createSubmenu(targetGroup: targetGroup)
    return item
  }

  // Creates submenu for target group
  private func createSubmenu(targetGroup: TargetGroup) -> NSMenu {
    let menu = NSMenu()
    for item in targetGroup.items {
      menu.items.append(createMenuItem(targetItem: item))
    }

    return menu
  } 

  // Creates menu item for target tree item
  private func createMenuItem(targetItem: TargetTreeItem) -> NSMenuItem {
    if let _ = targetItem as? TargetSeparator {
      return .separator()
    } else if let target = targetItem as? Target {
      return createMenuItem(target: target)
    } else if let group = targetItem as? TargetGroup {
      return createMenuItem(targetGroup: group)
    } else {
      fatalError("Unknown target tree item type")
    }
  }

  @IBAction func leftButtonDidClick(_ sender: Any) {
    guard isEnabled, let menu = targetsMenu else { return }

    let frame = leftParentView?.window?.convertToScreen(leftParentView!.convert(leftParentView!.bounds, to: nil))
    let location = frame?.origin ?? NSEvent.mouseLocation

    menu.popUp(positioning: menu.item(at: 0), at: location, in: nil)
  }


  @IBAction func rightButtonDidClick(_ sender: Any) {
    guard isEnabled, let menu = variantsMenu else { return }

    let frame = rightParentView?.window?.convertToScreen(rightParentView!.convert(rightParentView!.bounds, to: nil))
    let location = frame?.origin ?? NSEvent.mouseLocation

    menu.popUp(positioning: menu.item(at: 0), at: location, in: nil)
  }


  @objc func itemDidSelect(_ sender: Any?) {
    guard let item = sender as? NSMenuItem else { return }
    
    var selectedVariant: Variant?
    switch item.representedObject {

    case let target as Target:
      selectedVariant = target.variants.first

    case let variant as Variant:
      selectedVariant = variant

    case is String, is VariantsGroupMenuItem:
      itemDidSelect(item.submenu?.items.first)
      return

    default:
      selectedVariant = nil
    }

    NSApp.currentWorkbench?.selectedVariant = selectedVariant
    self.layer?.backgroundColor = .clear
  }

  private func select(variant: Variant) {
    // Target visuals
    if let targetIcon = variant.target.icon {
      leftImage?.isHidden = false
      leftImage?.image = targetIcon.image
    } else {
      leftImage?.isHidden = true
    }
    leftLable?.stringValue = variant.target.name

    // Variant visuals
    if let variantIcon = variant.icon {
      rightImage?.isHidden = false
      rightImage?.image = variantIcon.image
    } else {
      rightImage?.isHidden = true
    }
    rightLable?.stringValue = variant.name

    // Visuals
    separatorImage?.isHidden = false

    if !(rightLable?.stringValue.isEmpty ?? true) || rightImage != nil {
      rightParentView?.isHidden = false
    }
  }
}

extension ToolbarTargetControl: NSUserInterfaceValidations {
  func isActiveGroup(_ item: NSMenuItem?) -> Bool {
    guard let item = item,
          item.representedObject is VariantsGroupMenuItem else { return false }

    return item.submenu?.items.contains {
      ($0.representedObject as AnyObject) === activeVariant || isActiveGroup($0) } ?? false
  }

  func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let item = item as? NSMenuItem else {return true}
    switch item.representedObject {

    case let target as Target:
      item.state = (target === activeTarget) ? .on : .off

    case let variant as Variant:
      item.state = (variant === activeVariant) ? .on : .off

    case is String:
      let isActive = item.submenu?.items.contains{ ($0.representedObject as AnyObject) === activeTarget } ?? false
      item.state =  isActive ? .on : .off

    case is VariantsGroupMenuItem:
      item.state = isActiveGroup(item) ? .on : .off

    default:
      break
    }

    return true
  }
}

extension ToolbarTargetControl : NSMenuDelegate {
  func menuDidClose(_ menu: NSMenu) {
    guard let view = self.leftParentView else { return }
    let windowViewFrame = view.convert(view.frame, to: nil)
    if let window = view.window, windowViewFrame.contains(window.mouseLocationOutsideOfEventStream) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.leftButtonDidClick(self)
      }
    }
  }
}

// MARK: - BuildSystemsObserver

extension ToolbarTargetControl: BuildSystemsObserver {
  func availableTargetsDidChange(_ workbench: Workbench) {
    guard self.workbench === workbench else { return }
    self.targetsMenu = createTargetsMenu()
  }

  func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?) {
    guard self.workbench === workbench else { return }
    self.activeVariant = variant
  }
}
