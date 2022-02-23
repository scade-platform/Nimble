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

  private var _activeVariant: VariantRef?
  var activeVariant: Variant? {
    get { _activeVariant?.value  }
    set {
      if let newValue = newValue, newValue !== _activeVariant?.value {
        select(variant: newValue)
      }

      if newValue?.target !== activeTarget {
//        variantsMenu = createVariantsMenu(newValue)
      }

      _activeVariant = newValue?.ref
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
    colourAnim.toValue = highlightColor.cgColor
    colourAnim.duration = 1.0
    colourAnim.fillMode = .forwards
    colourAnim.isRemovedOnCompletion = false
    self.layer?.add(colourAnim, forKey: "backgroundColor")
    self.layer?.backgroundColor = highlightColor.cgColor
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

    for (name, targets) in BuildSystemsManager.shared.targetsGroupedByName(in: workbench) {
      guard targets.count > 1 else {
        addMenuItem(target: targets.first!, to: menu)
        continue
      }

      let targetItem = NSMenuItem(title: name,
                                  action: #selector(itemDidSelect(_:)), keyEquivalent: "")
      targetItem.target = self
      targetItem.representedObject = name

      let bsSubmenu = NSMenu()
      targets.forEach {
        let bsItem = NSMenuItem(title: $0.buildSystem.name,
                                action: #selector(itemDidSelect(_:)), keyEquivalent: "")

        bsItem.target = self
        bsItem.representedObject = $0
        bsItem.submenu = createSubmenus(for: $0)

        bsSubmenu.addItem(bsItem)
      }

      targetItem.submenu = bsSubmenu
      menu.addItem(targetItem)
    }

    guard !menu.items.isEmpty else { return nil }
    return menu
  }

  private func createVariantsMenu(_ variant: Variant?) -> NSMenu? {

    guard let target = variant?.target, let workbench = target.workbench else {
      return nil
    }

    //Triger to update variants
    let _ = BuildSystemsManager.shared.targetsGroupedByName(in: workbench)

    guard let menu = createSubmenus(for: target) else { return nil}

    menu.delegate = self

    guard !menu.items.isEmpty else { return nil }
    return menu
  }

  private func addMenuItem(target: Target, to menu: NSMenu) {
    let item = NSMenuItem(title: target.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = target
    item.submenu = createSubmenus(for: target)
    menu.addItem(item)
  }
  
  private func createSubmenus(for target: Target) -> NSMenu? {
    guard !target.variants.isEmpty else { return nil }

    let menu = NSMenu()
    let groups = target.variantsGroups

    if groups.count > 0 {
      // Split groups into groups and subgroups
      var groupItems: [NSMenuItem] = []
      var subgroupItems: [(UInt, NSMenuItem)] = []

      let allGroupItems: [NSMenuItem] = groups.map {
        let item = createGroupItem(for: $0)
        if let parent = target.group(for: $0) {
          subgroupItems.append((parent, item))
        } else {
          groupItems.append(item)
        }
        return item
      }

      func appendItem(_ item: NSMenuItem, at index: UInt?) {
        guard let index = index, index < allGroupItems.count else { return }
        allGroupItems[Int(index)].submenu?.items.append(item)
      }

      func appendSeparator(at index: UInt?) {
        guard let index = index,
              index < allGroupItems.count,
              var items = allGroupItems[Int(index)].submenu?.items,
              items.count > 0 else { return }

        items.append(.separator())
        allGroupItems[Int(index)].submenu?.items = items
      }

      // Add variants into groups
      var prevVariant: Variant?
      target.variants.forEach {
        let index = target.group(for: $0)
        if let prevVariant = prevVariant, type(of: prevVariant) != type(of: $0) {
          appendSeparator(at: index)
        }
        appendItem(createItem(for: $0), at: index)
        prevVariant = $0
      }

      var splittedGroups: Set<UInt> = []
      subgroupItems.forEach {
        if !splittedGroups.contains($0.0) {
          appendSeparator(at: $0.0)
          splittedGroups.insert($0.0)
        }
        appendItem($0.1, at: $0.0)
      }
      menu.items = groupItems

    } else {
      menu.items = target.variants.map { createItem(for: $0) }
    }

    return menu
  }

  private func createItem(for variant: Variant) -> NSMenuItem {
    let item = NSMenuItem(title: variant.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = variant
    return item
  }

  private func createGroupItem(for group: String) -> NSMenuItem {
    let item = NSMenuItem(title: group, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    item.submenu = NSMenu()
    item.representedObject = VariantsGroupMenuItem(title: group)
    return item
  }

  @IBAction func leftButtonDidClick(_ sender: Any) {
    guard isEnabled, let menu = createTargetsMenu() else { return }

    let frame = leftParentView?.window?.convertToScreen(leftParentView!.convert(leftParentView!.bounds, to: nil))
    let location = frame?.origin ?? NSEvent.mouseLocation

    menu.popUp(positioning: menu.item(at: 0), at: location, in: nil)
  }


  @IBAction func rightButtonDidClick(_ sender: Any) {
    guard isEnabled, let menu = createVariantsMenu(activeVariant) else { return }

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
    if let targetIcon = variant.target?.icon {
      leftImage?.isHidden = false
      leftImage?.image = targetIcon.image
    } else {
      leftImage?.isHidden = true
    }
    leftLable?.stringValue = variant.target?.name ?? ""

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
//    self.targetsMenu = createTargetsMenu()
  }

  func workbenchDidChangeVariant(_ workbench: Workbench, variant: Variant?) {
    guard self.workbench === workbench else { return }
    self.activeVariant = variant
  }
}
