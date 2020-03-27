//
//  Toolbar.swift
//  Nimble
//
//  Created by Danil Kristalev on 27/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


class Toolbar: NSObject {
  var identifier: NSUserInterfaceItemIdentifier?
  
  var delegate: ToolbarDelegate?
  private(set) var items: [ToolbarItem] = []
  
  lazy var defaultItems: [ToolbarItem] = {
    let result = self.delegate?.toolbarDefaultItems(self) ?? []
    items.append(contentsOf: result)
    return result
  }()
  
  lazy var defaultItemIdentifiers: [NSToolbarItem.Identifier] = {
    return self.defaultItems.map{$0.identifier}
  }()
  
  init(_ window: NSWindow) {
    super.init()
    self.identifier = NSUserInterfaceItemIdentifier("MainToolbar")
    
    let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MainToolbar"))
    toolbar.allowsUserCustomization = true
    toolbar.displayMode = .default
    toolbar.delegate = self
    window.toolbar = toolbar
  }
  
}

extension Toolbar : NSToolbarDelegate {
  
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return defaultItemIdentifiers
  }
  
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return delegate?.toolbarItems(self).map{ $0.identifier } ?? defaultItemIdentifiers
  }
  
  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    guard let item = items.first(where: {$0.identifier == itemIdentifier}) else { return nil }
    
    switch item.kind {
    case .imageButton:
      return item.imagePushButton()
    case .segmentedControl:
      return item.segmentedControl()
    default:
      return nil
    }
  }
  
}

protocol ToolbarDelegate {
  func toolbarDefaultItems(_ toolbar: Toolbar) -> [ToolbarItem]
  
  func toolbarItems(_ toolbar: Toolbar) -> [ToolbarItem]
}

enum ToolbarItemKind {
  case imageButton
  case segmentedControl
  case segment
  case indefinite
}

struct ToolbarItem {
  let identifier: NSToolbarItem.Identifier
  let lable: String
  let palleteLable: String
  let image: NSImage?
  let width: CGFloat
  let height: CGFloat
  let action: Selector?
  weak var target: AnyObject?
  let group: [ToolbarItem]
  var delegate: ToolbarItemDelegate?
  
  
  class ToolbarItemBuilder {
    
    let identifier: NSToolbarItem.Identifier
    
    private var lable: String
    private var palleteLable: String
    private var image: NSImage?
    private var width: CGFloat
    private var height: CGFloat
    private var action: Selector?
    private weak var target: AnyObject?
    private var group: [ToolbarItem]
    private var delegate: ToolbarItemDelegate?
    
    init(rawIdentifierValue: String) {
      self.identifier = NSToolbarItem.Identifier(rawIdentifierValue)
      self.lable = ""
      self.palleteLable = ""
      self.width = .zero
      self.height = .zero
      self.group = []
    }
    
    init(identifier: NSToolbarItem.Identifier) {
      self.identifier = identifier
      self.lable = ""
      self.palleteLable = ""
      self.width = .zero
      self.height = .zero
      self.group = []
    }
    
    @discardableResult
    func lable(_ l: String) -> ToolbarItemBuilder {
      self.lable = l
      return self
    }
    
    @discardableResult
    func palleteLable(_ pl: String) -> ToolbarItemBuilder {
      self.palleteLable = pl
      return self
    }
    
    @discardableResult
    func image(_ img: NSImage) -> ToolbarItemBuilder {
      self.image = img
      return self
    }
    
    @discardableResult
    func width(_ w: CGFloat) -> ToolbarItemBuilder {
      self.width = w
      return self
    }
    
    @discardableResult
    func height(_ h: CGFloat) -> ToolbarItemBuilder {
      self.height = h
      return self
    }
    
    @discardableResult
    func set(target: AnyObject, action: Selector) -> ToolbarItemBuilder {
      self.action = action
      self.target = target
      return self
    }
    
    @discardableResult
    func group(_ items: [ToolbarItem]) -> ToolbarItemBuilder {
      self.group = items
      return self
    }
    
    @discardableResult
    func delegate(_ d: ToolbarItemDelegate) -> ToolbarItemBuilder {
      self.delegate = d
      return self
    }
    
    func build() -> ToolbarItem {
      return ToolbarItem(identifier: self.identifier, lable: self.lable, palleteLable: self.palleteLable, image: self.image, width: self.width, height: self.height, action: self.action, target: self.target, group: self.group, delegate: self.delegate)
    }
  }
}

extension ToolbarItem {
  var isEnabled: Bool {
    return delegate?.isEnabled(self) ?? true
  }
  
  var isSelected: Bool {
    return delegate?.isSelected(self) ?? false
  }
  
  var kind: ToolbarItemKind {
    return delegate?.kind(self) ?? .indefinite
  }
}

protocol ToolbarItemDelegate {
  func isEnabled(_ toolbarItem: ToolbarItem) -> Bool
  func isSelected(_ toolbarItem: ToolbarItem) -> Bool
  func kind(_ toolbarItem: ToolbarItem) -> ToolbarItemKind
}

extension ToolbarDelegate {
  func isEnabled(_ toolbarItem: ToolbarItem) -> Bool {
    return false
  }
  
  func isSelected(_ toolbarItem: ToolbarItem) -> Bool {
    return false
  }
  
  func kind(_ toolbarItem: ToolbarItem) -> ToolbarItemKind {
    return .indefinite
  }
}


extension ToolbarItem {
  static public func builder(rawIdentifierValue value: String) -> ToolbarItem.ToolbarItemBuilder {
    return ToolbarItem.ToolbarItemBuilder(rawIdentifierValue: value)
  }
  
  static public func builder(identifier id: NSToolbarItem.Identifier) -> ToolbarItem.ToolbarItemBuilder {
    return ToolbarItem.ToolbarItemBuilder(identifier: id)
  }
}

extension ToolbarItem {
  public static let flexibleSpace = ToolbarItem.builder(identifier: .flexibleSpace).build()
  
  public static let separator = ToolbarItem.builder(identifier: .separator).build()
  
  public static let space = ToolbarItem.builder(identifier: .space).build()
}

extension ToolbarItem {
  func imagePushButton() -> NSToolbarItem {
    let item = NSToolbarItem(itemIdentifier: self.identifier)
    item.label = self.lable
    item.label = self.palleteLable
    
    let button = NSButton(image: self.image!, target: self.target, action: self.action)
    button.cell = ToolbarItemButtonCell()
    button.imageScaling = .scaleProportionallyDown
    button.bezelStyle = .texturedRounded
    button.focusRingType = .none
    button.widthAnchor.constraint(equalToConstant: self.width).isActive = true
    
    item.view = button
    item.isEnabled = self.isEnabled
    
    return item
  }
  
  private class ToolbarItemButtonCell: NSButtonCell {
    
    override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
      //set top and bottom paddings for image
      super.drawImage(image, withFrame: frame.insetBy(dx: 0, dy: 2), in: controlView)
    }
    
  }
}

extension ToolbarItem {
  func segmentedControl() -> NSToolbarItemGroup {
    let itemGroup = NSToolbarItemGroup(itemIdentifier: self.identifier)
    
    let segmentedControl = NSSegmentedControl(frame: NSRect(x: 0, y: 0, width: self.group.reduce(0){$0 + $1.width}, height: 0))
    segmentedControl.cell = ToolbarItemSegmentedCell()
    segmentedControl.segmentCount = self.group.count
    segmentedControl.trackingMode = .selectAny
    segmentedControl.focusRingType = .none
    segmentedControl.segmentStyle = .texturedRounded
    
    if self.action == nil, self.target == nil {
      let wrapper = NSObjectToolbatItemWrapper(self)
      segmentedControl.target = wrapper
      segmentedControl.action = #selector(wrapper.execute(_:))
    } else {
      segmentedControl.target = self.target
      segmentedControl.action = self.action
    }
    
    var subitems: [NSToolbarItem] = []
    for (index, segment) in group.enumerated() {
      let item = NSToolbarItem(itemIdentifier: segment.identifier)
      item.action = segment.action
      item.target = segment.target
      subitems.append(item)
      
      segmentedControl.setImage(segment.image, forSegment: index)
      segmentedControl.setWidth(segment.width, forSegment: index)
      segmentedControl.setEnabled(segment.isEnabled, forSegment: index)
      segmentedControl.setSelected(segment.isSelected, forSegment: index)
    }
    
    itemGroup.paletteLabel = self.palleteLable
    itemGroup.subitems = subitems
    itemGroup.view = segmentedControl
    
    return itemGroup
  }
  
  private class NSObjectToolbatItemWrapper: NSObject {
    let wrappedToolbarItem: ToolbarItem
    
    init(_ wrapped: ToolbarItem) {
      self.wrappedToolbarItem = wrapped
      super.init()
    }
    
    @objc func execute(_ sender: Any?) {
      //redirect to selected segment
      guard let segmentedControl = sender as? NSSegmentedControl else { return }
      let toolbarItem = wrappedToolbarItem.group[segmentedControl.selectedSegment]
      NSApp.sendAction(toolbarItem.action!, to: toolbarItem.target, from: nil)
    }
    
  }
  
  private class ToolbarItemSegmentedCell: NSSegmentedCell {
    
    override func drawSegment(_ segment: Int, inFrame frame: NSRect, with controlView: NSView) {
      guard let imageSize = image(forSegment: segment)?.size else { return }
      
      let imageRect = computeImageRect(imageSize: imageSize, in: frame)
      
      let selectedColor = NSColor(named: "SelectedSegmentColor", bundle: Bundle.main)
      let defaulColor = NSColor(named: "BottonIconColor", bundle: Bundle.main)
      let tintColor: NSColor = (isSelected(forSegment: segment) ? selectedColor : defaulColor) ?? .darkGray
      
      if let image = image(forSegment: segment)?.imageWithTint(tintColor) {
        //paddings is equal 2
        image.draw(in: imageRect.insetBy(dx: 2, dy: 2))
      }
    }
    
    func computeImageRect(imageSize: NSSize, in frame: NSRect) -> NSRect {
      var targetScaleSize = frame.size
      
      //Scale proportionally down
      if targetScaleSize.width > imageSize.width { targetScaleSize.width = imageSize.width }
      if targetScaleSize.height > imageSize.height { targetScaleSize.height = imageSize.height }
      
      let scaledSize = self.sizeByScalingProportianlly(toSize: targetScaleSize, fromSize: imageSize)
      let drawingSize = NSSize(width: scaledSize.width, height: scaledSize.height)
      
      //Image position inside the content frame (center)
      let drawingPosition = NSPoint(x: frame.origin.x + frame.size.width / 2 - drawingSize.width / 2,
                                    y: frame.origin.y + frame.size.height / 2 - drawingSize.height / 2)

      return NSRect(x: round(drawingPosition.x), y: round(drawingPosition.y), width: ceil(drawingSize.width), height: ceil(drawingSize.height))
    }
    
    
    func sizeByScalingProportianlly(toSize newSize: NSSize, fromSize oldSize: NSSize) -> NSSize {
        let widthHeightDivision = oldSize.width / oldSize.height
        let heightWidthDivision = oldSize.height / oldSize.width

        var scaledSize = NSSize.zero

        if oldSize.width > oldSize.height {
            if (widthHeightDivision * newSize.height) >= newSize.width {
                scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
            } else {
                scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
            }
        } else {
            if (heightWidthDivision * newSize.width) >= newSize.height {
                scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
            } else {
                scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
            }
        }
        return scaledSize
    }
  }
}
