//
//  Command+Toolbar.swift
//  Nimble
//
//  Created by Grigory Markin on 19.04.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

extension Command {
  fileprivate static let toolbarItemWidth: CGFloat = 38.0

  var toolbarItemIdentifier: NSToolbarItem.Identifier { NSToolbarItem.Identifier(rawValue: self.name) }

  func toolbarItem(in workbench: Workbench) -> NSToolbarItem? {
    guard let workbench = workbench as? NimbleWorkbench else { return nil }
    return workbench.toolbarItems.first{$0.itemIdentifier == self.toolbarItemIdentifier}
  }

  func createToolbarItem() -> NSToolbarItem {
    let item = ToolbarItem(itemIdentifier: self.toolbarItemIdentifier)
    item.label = self.name
    
    item.view = self.view
    return item
  }
  
  var view: NSView {
    guard self.toolbarView == nil else {
      return self.toolbarView!
    }
    
    let button = NSButton()
    button.cell = ToolbarItemButtonCell()

    button.image = self.toolbarIcon
    button.title = ""
    button.imageScaling = .scaleProportionallyUpOrDown
    button.bezelStyle = .texturedRounded
    button.focusRingType = .none
    button.widthAnchor.constraint(equalToConstant: Command.toolbarItemWidth).isActive = true

    button.target = self
    button.action = #selector(Command.execute)
    
    return button
  }

  private class ToolbarItemButtonCell: NSButtonCell {
      // override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
      //   let color = NSColor(named: "ButtonIconColor", bundle: Bundle.main) ?? .darkGray
      //   let img = image.imageWithTint(color)
      //   //set top and bottom paddings for image
      //   super.drawImage(img, withFrame: frame.insetBy(dx: 0, dy: 2), in: controlView)
      // }
  }

  private class ToolbarItem: NSToolbarItem {
    override func validate() {
      guard let workbench = NimbleWorkbench.current,
            let command = self.target as? Command else { return }

      self.isEnabled = command.validate(in: workbench).contains(.enabled)
    }
  }
}


extension CommandGroup {
  var toolbarItemIdentifier: NSToolbarItem.Identifier { NSToolbarItem.Identifier(rawValue: self.name) }

  func toolbarItem(in workbench: Workbench) -> NSToolbarItem? {
    guard let workbench = workbench as? NimbleWorkbench else { return nil }
    return workbench.toolbarItems.first{$0.itemIdentifier == self.toolbarItemIdentifier}
  }

  func createToolbarItem() -> NSToolbarItemGroup {
    let itemGroup = ToolbarItem(itemIdentifier: self.toolbarItemIdentifier)
    let segmentedControl = NSSegmentedControl(frame: NSRect(x: 0,
                                                            y: 0,
                                                            width: Command.toolbarItemWidth * CGFloat(commands.count),
                                                            height: 0))

    segmentedControl.cell = ToolbarItemSegmentedCell()
    segmentedControl.segmentCount = commands.count
    segmentedControl.trackingMode = .selectAny
    segmentedControl.focusRingType = .none
    segmentedControl.segmentStyle = .texturedRounded

    segmentedControl.target = self
    segmentedControl.action = #selector(execute(_:))

    var subitems: [NSToolbarItem] = []
    for (index, cmd) in commands.enumerated() {
      let item = NSToolbarItem(itemIdentifier: cmd.toolbarItemIdentifier)
      subitems.append(item)

      segmentedControl.setImage(cmd.toolbarIcon, forSegment: index)
      segmentedControl.setWidth(Command.toolbarItemWidth, forSegment: index)
    }

    itemGroup.paletteLabel = self.title
    itemGroup.subitems = subitems
    itemGroup.view = segmentedControl

    return itemGroup
  }

  @objc func execute(_ sender: Any?) {
    guard let segmentedControl = sender as? NSSegmentedControl else { return }
    commands[segmentedControl.selectedSegment].execute()
  }

  private class ToolbarItem: NSToolbarItemGroup {
    override func validate() {
      guard let workbench = NimbleWorkbench.current,
            let command = self.target as? CommandGroup,
            let control = self.view as? NSSegmentedControl else { return }

      for (index, cmd) in command.commands.enumerated() {
        let state = cmd.validate(in: workbench)
        control.setEnabled(state.contains(.enabled), forSegment: index)
        control.setSelected(state.contains(.selected), forSegment: index)
      }
    }
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
