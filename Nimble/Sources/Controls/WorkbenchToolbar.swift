//
//  WorkbenchToolbar.swift
//  Nimble
//
//  Created by Danil Kristalev on 27/03/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


class WorkbenchToolbar: NSObject {
  var delegate: ToolbarDelegate?
  private(set) var items: [ToolbarItem] = []
  
  weak var nsWindow: NSWindow?
  
  lazy var defaultItems: [ToolbarItem] = {
    let result = self.delegate?.toolbarDefaultItems(self) ?? []
    items.append(contentsOf: result)
    return result
  }()
  
  lazy var defaultItemIdentifiers: [NSToolbarItem.Identifier] = {
    return self.defaultItems.map{$0.identifier}
  }()
  
  init(_ window: NSWindow, delegate: ToolbarDelegate? = nil) {
    super.init()
    
    let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MainToolbar"))
    toolbar.allowsUserCustomization = true
    toolbar.displayMode = .default
    toolbar.delegate = self
    self.delegate = delegate
    nsWindow = window
    window.toolbar = toolbar
  }
  
}

extension WorkbenchToolbar : NSToolbarDelegate {
  
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return defaultItemIdentifiers
  }
  
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return delegate?.toolbarAllowedItems(self).map{ $0.identifier } ?? defaultItemIdentifiers
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
  
  
  func toolbarWillAddItem(_ notification: Notification) {
    guard let newItem = notification.userInfo?["item"] as? NSToolbarItem else { return }
    if let item = items.first(where: {$0.identifier == newItem.itemIdentifier}) {
      delegate?.toolbarWillAddItem(self, item: item)
    }
  }
  
  func toolbarDidRemoveItem(_ notification: Notification) {
    guard let removedItem = notification.userInfo?["item"] as? NSToolbarItem else { return }
    if let item = items.first(where: {$0.identifier == removedItem.itemIdentifier}) {
      delegate?.toolbarDidRemoveItem(self, item: item)
    }
  }
}

protocol ToolbarDelegate {
  func toolbarDefaultItems(_ toolbar: WorkbenchToolbar) -> [ToolbarItem]
  func toolbarAllowedItems(_ toolbar: WorkbenchToolbar) -> [ToolbarItem]
  func toolbarWillAddItem(_ toolbar: WorkbenchToolbar, item: ToolbarItem)
  func toolbarDidRemoveItem(_ toolbar: WorkbenchToolbar, item: ToolbarItem)
}

enum ToolbarItemKind {
  case imageButton
  case segmentedControl
  case segment
  case indefinite
}

class ToolbarItem: NSObject {
  let identifier: NSToolbarItem.Identifier
  let kind: ToolbarItemKind
  let lable: String
  let palleteLable: String
  let image: NSImage?
  let width: CGFloat
  let height: CGFloat
  let action: Selector?
  weak var target: AnyObject?
  let group: [ToolbarItem]
  var delegate: ToolbarItemDelegate?
  weak var toolbar: WorkbenchToolbar?
  
  init(identifier: NSToolbarItem.Identifier, kind: ToolbarItemKind = .indefinite, lable: String = "", palleteLable: String = "", image: NSImage? = nil, width: CGFloat = .zero, height: CGFloat = .zero, action: Selector? = nil, target: AnyObject? = nil, group: [ToolbarItem] = [], toolbar: WorkbenchToolbar? = nil, delegate: ToolbarItemDelegate? = nil){
    self.identifier = identifier
    self.kind = kind
    self.lable = lable
    self.palleteLable = palleteLable
    self.image = image
    self.width = width
    self.height = height
    self.action = action
    self.target = target
    self.group = group
    self.toolbar = toolbar
    self.delegate = delegate
  }
  
}

extension ToolbarItem {
  var isEnabled: Bool {
    return delegate?.isEnabled(self) ?? true
  }
  
  var isSelected: Bool {
    return delegate?.isSelected(self) ?? false
  }
}

protocol ToolbarItemDelegate {
  func isEnabled(_ toolbarItem: ToolbarItem) -> Bool
  func isSelected(_ toolbarItem: ToolbarItem) -> Bool
}

extension ToolbarItemDelegate {
  func isEnabled(_ toolbarItem: ToolbarItem) -> Bool {
    return false
  }
  
  func isSelected(_ toolbarItem: ToolbarItem) -> Bool {
    return false
  }
}


extension ToolbarItem {
  public static let flexibleSpace = ToolbarItem(identifier: .flexibleSpace)
  
  public static let separator = ToolbarItem(identifier: .separator)
  
  public static let space = ToolbarItem(identifier: .space)
}

extension ToolbarItem {
  func imagePushButton() -> NSToolbarItem {
    let item = NSToolbarItem(itemIdentifier: self.identifier)
    item.label = self.lable
    
    let button = NSButton()
    button.cell = ToolbarItemButtonCell()
    button.image = self.image
    button.action = self.action
    button.target = self.target
    button.title = ""
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
      let color = NSColor(named: "ButtonIconColor", bundle: Bundle.main) ?? .darkGray
      let img = image.imageWithTint(color)
      //set top and bottom paddings for image
      super.drawImage(img, withFrame: frame.insetBy(dx: 0, dy: 2), in: controlView)
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
      segmentedControl.target = self
      segmentedControl.action = #selector(execute(_:))
    } else {
      segmentedControl.target = self.target
      segmentedControl.action = self.action
    }
    
    var subitems: [NSToolbarItem] = []
    for (index, segment) in group.enumerated() {
      let item = NSToolbarItem(itemIdentifier: segment.identifier)
      item.action = segment.action
      item.target = segment
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
  
  @objc func execute(_ sender: Any?) {
    //redirect to selected segment
    guard let segmentedControl = sender as? NSSegmentedControl else { return }
    let toolbarItem = self.group[segmentedControl.selectedSegment]
    NSApp.sendAction(toolbarItem.action!, to: toolbarItem.target, from: nil)
  }
  
  private class ToolbarItemSegmentedCell: NSSegmentedCell {
    
    override func drawSegment(_ segment: Int, inFrame frame: NSRect, with controlView: NSView) {
      guard let imageSize = image(forSegment: segment)?.size else { return }
      
      let imageRect = computeImageRect(imageSize: imageSize, in: frame)
      
      let selectedColor = NSColor(named: "SelectedSegmentColor", bundle: Bundle.main)
      let defaulColor = NSColor(named: "ButtonIconColor", bundle: Bundle.main)
      let tintColor: NSColor = (isSelected(forSegment: segment) ? selectedColor : defaulColor) ?? .darkGray
      
      if let image = image(forSegment: segment)?.imageWithTint(tintColor) {
        //paddings is equal 2
        image.draw(in: imageRect.insetBy(dx: 3, dy: 3))
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
