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
  
  @IBOutlet weak var leftParentView: NSView?
  @IBOutlet weak var leftImage: NSImageView?
  @IBOutlet weak var leftLable: NSTextField?
  
  @IBOutlet weak var separatorImage: NSImageView?
  
  @IBOutlet weak var rightParentView: NSView? 
  @IBOutlet weak var rightImage: NSImageView?
  @IBOutlet weak var rightLable: NSTextField?
  
  //Last target and variant selected by user
  private var userSelection: (target: Target, variant: Variant)?
  
  //Current target which could be selected by the control
  private var activeTarget: Target?
  
  //Temp storage for menu item targets
  private var menuItemTargets: [Target] = []
  //Dictinory with targets by name
  private var automaticTargets: [String: [Target]] = [:]
  
  weak var borderLayer: CALayer?
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        leftLable?.textColor = .labelColor
        rightLable?.textColor = .labelColor
      } else {
        //Disable means there aren't any targets
        dropTarget()
        
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
    self.wantsLayer = true
    let layer = CAGradientLayer()
    
    layer.masksToBounds = true
    layer.cornerRadius = 4.5
    layer.colors = [self.bottomBackgroundColor.cgColor, self.topBackgroundColor.cgColor]
    self.layer = layer
    addGradienBorder(colors: [self.bottomBorderColor, self.topBorderColor])
    
    
  }
  
  override func layout() {
    if let layer = self.layer as? CAGradientLayer {
      //change colors after system theme changed
      layer.colors = [self.bottomBackgroundColor.cgColor, self.topBackgroundColor.cgColor]
      addGradienBorder(colors: [self.bottomBorderColor, self.topBorderColor])
    }
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
    NSColor(named: "ControlBackgroundColor", bundle: Bundle(for: ToolbarTargetControl.self)) ?? NSColor.controlColor
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.separatorImage?.imageScaling = .scaleProportionallyDown
    self.separatorImage?.image = separatorTemplate
    
    dropTarget()
  }
  
  func dropTarget() {
    self.activeTarget = nil
    self.userSelection = nil
    if let window = self.window {
      selectedVariants.removeValue(forKey: ObjectIdentifier(window))
    }
    
    self.leftImage?.isHidden = true
    self.leftLable?.stringValue = "No Targets"
    
    self.separatorImage?.isHidden = true
    
    self.rightParentView?.isHidden = true
    self.rightImage?.isHidden = true
    self.rightLable?.stringValue = ""
    
    menuItemTargets = []
    automaticTargets = [:]
  }
  
  override func viewWillMove(toWindow newWindow: NSWindow?) {
    guard let window = self.window, newWindow == nil else { return }
    selectedVariants.removeValue(forKey: ObjectIdentifier(window))
  }
  
  func updateTargets(in workbench: Workbench) {
    menuItemTargets = []
    automaticTargets = [:]
    
    guard let buildSystem = BuildSystemsManager.shared.activeBuildSystem else { return }
    if let automatic = buildSystem as? Automatic {
      automaticTargets = [:]
      menuItemTargets = automatic.targets(in: workbench)
      for target in menuItemTargets {
        if let _ = automaticTargets[target.name] {
          automaticTargets[target.name]?.append(target)
        } else {
          automaticTargets[target.name] = [target]
        }
      }
    } else {
      menuItemTargets = buildSystem.targets(in: workbench)
    }
  }
  
  func autoSelectTarget(in workbench: Workbench) {
    guard let targets = BuildSystemsManager.shared.activeBuildSystem?.targets(in: workbench) else {
      return
    }
    
    let currentTargetName = activeTarget?.name ?? ""
    let currentVariantName = workbench.selectedVariant?.name ?? ""
    
    if menuItemTargets.isEmpty ||
      menuItemTargets.count != targets.count {
      activeTarget = nil
      workbench.selectedVariant = nil
      updateTargets(in: workbench)
    }
    
    guard activeTarget == nil, workbench.selectedVariant == nil else { return }
    
    var buildTarget: Target
    var variant: Variant
    
    if let t = menuItemTargets.first(where: {$0.name == currentTargetName}),
       let v = t.variants.first(where: {$0.name == currentVariantName}) {
      buildTarget = t
      variant = v
    } else if let t = menuItemTargets.first,
              let v = t.variants.first {
      buildTarget = t
      variant = v
    } else {
      return
    }
    
    
    set(target: buildTarget)
    separatorImage?.isHidden = false
    set(variant: variant)
    
    if !(rightLable?.stringValue.isEmpty ?? true) || rightImage != nil {
      rightParentView?.isHidden = false
    }
    
    if userSelection == nil {
      self.userSelection = (buildTarget, variant)
    }
    
    if OSLog.isLogOn {
      os_log("Auto-selected build target: %{public}s", log: .targetSelector, type: .info, buildTarget.name)
    }
    
    activeTarget = buildTarget
    workbench.selectedVariant = variant
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
    return createSubmenus(for: target.variants)
  }
  
  private func createSubmenus(for variants: [Variant]) -> NSMenu? {
    let menu = NSMenu()
    for variant in variants {
      let item = NSMenuItem(title: variant.name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
      item.target = self
      item.representedObject = variant
      menu.addItem(item)
    }
    return menu
  }
  
  @IBAction func leftButtonDidClick(_ sender: Any) {
    if OSLog.isLogOn {
      os_log("Target selector did clicked", log: .targetSelector, type: .info)
    }
    
    guard self.isEnabled else {
      return
    }
    
    let menu = NSMenu()
    if BuildSystemsManager.shared.activeBuildSystem is Automatic {
      let sortedAutomaticTargets = automaticTargets.map{($0.key, $0.value)}.sorted{$0.0 < $1.0}
      for (name, targets) in sortedAutomaticTargets {
        let allVariants = targets.map{$0.variants}
        let buildSystemNames = allVariants.compactMap{ $0.first?.buildSystem?.name }
        let item = NSMenuItem(title: name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = name
        let buildSystemSubmenu = NSMenu()
        for (index, (name, variants)) in zip(buildSystemNames, allVariants).enumerated() {
          let buildSystemMenuItem = NSMenuItem(title: name, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
          buildSystemMenuItem.target = self
          buildSystemMenuItem.representedObject = targets[index]
          buildSystemMenuItem.submenu = createSubmenus(for: variants)
          buildSystemSubmenu.addItem(buildSystemMenuItem)
        }
        item.submenu = buildSystemSubmenu
        menu.addItem(item)
      }
    } else {
      guard !menuItemTargets.isEmpty else {
        return
      }
      menuItemTargets.forEach{addMenuItem(target: $0, to: menu)}
    }
    
    guard !menu.items.isEmpty else {
      return
    }
     let frame = leftParentView?.window?.convertToScreen(leftParentView!.convert(leftParentView!.bounds, to: nil))
         let location = frame?.origin ?? NSEvent.mouseLocation
    menu.popUp(positioning: menu.item(at: 0), at: location, in: nil)
  }
  
  @IBAction func rightButtonDidClick(_ sender: Any) {
    guard self.isEnabled, let workbench = NSApp.currentWorkbench, let variant = workbench.selectedVariant, let target = variant.target else {
      return
    }
    if let menu = creatSubmenus(target: target) {
      menu.delegate = self
      let frame = rightParentView?.window?.convertToScreen(rightParentView!.convert(rightParentView!.bounds, to: nil))
      let location = frame?.origin ?? NSEvent.mouseLocation
      menu.popUp(positioning: menu.item(at: 0), at: location, in: nil)
    }
  }
  
  @objc func itemDidSelect(_ sender: Any?) {
    guard let item = sender as? NSMenuItem else {
      return
    }
    
    let selectedVariant: Variant?
    if let variant = item.representedObject as? Variant {
      set(target: variant.target)
      separatorImage?.isHidden = false
      set(variant: variant)
      selectedVariant = variant
    } else if let target = item.representedObject as? Target {
      set(target: target)
      separatorImage?.isHidden = false
      selectedVariant = target.variants.first
      set(variant: selectedVariant)
    } else {
      selectedVariant = nil
    }
    
    if !(rightLable?.stringValue.isEmpty ?? true) || rightImage != nil {
      rightParentView?.isHidden = false
    }
    
    guard let workbench = NSApp.currentWorkbench, let variant = selectedVariant else {
      return
    }
    
    userSelection = (variant.target!, variant)
    activeTarget = variant.target
    workbench.selectedVariant = variant
  }
  
  private func set(target: Target?) {
    if let targetIcon = target?.icon {
      leftImage?.isHidden = false
      leftImage?.image = targetIcon.image
    } else {
      leftImage?.isHidden = true
    }
    leftLable?.stringValue = target?.name ?? ""
  }
  
  private func set(variant: Variant?) {
    if let variantIcon = variant?.icon {
      rightImage?.isHidden = false
      rightImage?.image = variantIcon.image
    } else {
      rightImage?.isHidden = true
    }
    rightLable?.stringValue = variant?.name ?? ""
  }
}

extension ToolbarTargetControl: NSUserInterfaceValidations {
  func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let item = item as? NSMenuItem else {return true}
    if let target = item.representedObject as? Target {
      item.state = (target.id  == activeTarget?.id) ? .on : .off
    } else if let varint = item.representedObject as? Variant {
//      item.state = (varint.target?.id == activeTarget?.id && varint.name == userSelection?.variant.name) ? .on : .off
      if let variantValidator = varint as? NSUserInterfaceValidations {
        variantValidator.validateUserInterfaceItem(item)
      }
    } else if let name = item.representedObject as? String {
      item.state = (activeTarget?.name == name) ? .on : .off
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

extension ToolbarTargetControl : WorkbenchObserver {
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) {
    guard let buildSystem = BuildSystemsManager.shared.activeBuildSystem else { return }
    let avalibleTargets = buildSystem.targets(in: workbench)
    guard let file = document?.fileURL?.file, let target = avalibleTargets.first(where: {($0.contains(file: file))}) else {
      guard let (selectedTarget, selectedVariant) = userSelection, avalibleTargets.contains(where: {$0.name == selectedTarget.name}) else {
        self.userSelection = nil
        self.activeTarget = nil
        workbench.selectedVariant = nil
        return
      }
      
      
      set(target: selectedTarget)
      separatorImage?.isHidden = false
      set(variant: selectedVariant)
      
      activeTarget = selectedTarget
      workbench.selectedVariant = selectedVariant
      
      return
    }
    set(target: target)
    separatorImage?.isHidden = false
    let selectedVariant = target.variants.first
    set(variant: selectedVariant)
    
    activeTarget = target
    workbench.selectedVariant = selectedVariant
    
    if !(rightLable?.stringValue.isEmpty ?? true) || rightImage != nil {
      rightParentView?.isHidden = false
    }
  }
}

extension ToolbarTargetControl: ProjectObserver {
  func projectFoldersDidChange(_: Project) {
    menuItemTargets = []
    automaticTargets = [:]
  }
}

extension ToolbarTargetControl: BuildSystemsObserver {
  func activeBuildSystemDidChange(deactivatedBuildSystem: BuildSystem?, activeBuildSystem: BuildSystem?) {
    self.activeTarget = nil
    self.userSelection = nil
    if let window = self.window {
      selectedVariants.removeValue(forKey: ObjectIdentifier(window))
    }
    
    menuItemTargets = []
    automaticTargets = [:]
  }
}


extension OSLog {
  private static let subsystem = "com.nimble.BuildSystem"
  
  static let targetSelector = OSLog(subsystem: subsystem, category: "targetSelector")
  
  @Setting("nimble.log", defaultValue: [])
  public static var logsSystems: [String]
  
  static var isLogOn : Bool {
    return OSLog.logsSystems.contains(OSLog.subsystem)
  }
}

