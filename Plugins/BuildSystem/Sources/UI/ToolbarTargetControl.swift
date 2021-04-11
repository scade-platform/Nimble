//
//  ToolbarTargetControl.swift
//  Nimble
//
//  Created by Danil Kristalev on 20.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import BuildSystem
import os.log

class ToolbarTargetControl : NSControl {
  private struct VariantsGroupMenuItem {
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

  private var targetsMenu: NSMenu?
  private var variantsMenu: NSMenu?

  /// TODO: move to an extension and disable explicit passing of the reference to view everywhere
  private var workbench: Workbench? {
    self.window?.windowController as? Workbench
  }

  private var _activeVariant: VariantRef?
  var activeVariant: Variant? {
    get { _activeVariant?.value  }
    set {
      if let newValue = newValue, newValue !== _activeVariant?.value {
        select(variant: newValue)
      }

      if newValue?.target !== activeTarget {
        variantsMenu = createVariantsMenu(newValue)
      }

      _activeVariant = newValue?.ref
    }
  }

  var activeTarget: Target? {
    activeVariant?.target
  }

  var workbenchTargets: [Target] {
    guard let workbench = self.workbench else { return [] }
    return BuildSystemsManager.shared.targets(in: workbench)
  }

  private var targetsGroupedByName: [String: [Target]] {
    var groups: [String: [Target]] = [:]

    // Group targets by name
    workbenchTargets.forEach {
      var targets = groups[$0.name] ?? []
      targets.append($0)
      groups.updateValue(targets, forKey: $0.name)
    }

    return groups
  }

  override var isEnabled: Bool {
    didSet {
      let textColor: NSColor = isEnabled ? .labelColor : .disabledControlTextColor
      leftLable?.textColor = textColor
      rightLable?.textColor = textColor

      if !isEnabled {
        clear()
      }
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
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)

    setupVisuals()
  }
  
  override func layout() {
    if let layer = self.layer as? CAGradientLayer {
      //change colors after system theme changed
      layer.colors = [self.bottomBackgroundColor.cgColor, self.topBackgroundColor.cgColor]
      addGradienBorder(colors: [self.bottomBorderColor, self.topBorderColor])
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    self.separatorImage?.imageScaling = .scaleProportionallyDown
    self.separatorImage?.image = separatorTemplate

    clear()
  }

  override func viewWillMove(toWindow newWindow: NSWindow?) {
    switch newWindow {
    case .some(_):
      self.activeVariant = (newWindow?.windowController as? Workbench)?.selectedVariant
      BuildSystemsManager.shared.observers.add(observer: self)
    default:
      BuildSystemsManager.shared.observers.remove(observer: self)
    }
  }


  private func setupVisuals() {
    let layer = CAGradientLayer()
    layer.masksToBounds = true
    layer.cornerRadius = 4.5
    layer.colors = [self.bottomBackgroundColor.cgColor,
                    self.topBackgroundColor.cgColor]

    self.wantsLayer = true
    self.layer = layer

    addGradienBorder(colors: [self.bottomBorderColor, self.topBorderColor])
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
    let menu = NSMenu()

    let sortedTargets = targetsGroupedByName.map{($0.key, $0.value)}.sorted{$0.0 < $1.0}

    for (name, targets) in sortedTargets {
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
    guard let target = variant?.target,
          let menu = createSubmenus(for: target) else { return nil}

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
    
    var selectedVariant: Variant? = nil

    if let variant = item.representedObject as? Variant {
      selectedVariant = variant

    } else if let target = item.representedObject as? Target {
      selectedVariant = target.variants.first

    } else if item.representedObject is VariantsGroupMenuItem,
              let submenu = item.submenu {

      itemDidSelect(submenu.items.first)
      return
    }

    NSApp.currentWorkbench?.selectedVariant = selectedVariant
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
  func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let item = item as? NSMenuItem else {return true}

    if let target = item.representedObject as? Target {
      item.state = (target === activeTarget) ? .on : .off

    } else if let variant = item.representedObject as? Variant {
      item.state = (variant === activeVariant) ? .on : .off

    } else if let group = item.representedObject as? VariantsGroupMenuItem {
      guard let activeVariant = activeVariant,
            let activeGroup = activeTarget?.group(for: activeVariant),
            let activeGroupName = activeTarget?.variantsGroups[safe: Int(activeGroup)] else { return true}

      item.state = (group.title == activeGroupName) ? .on : .off
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
