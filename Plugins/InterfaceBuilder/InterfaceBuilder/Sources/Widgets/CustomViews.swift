//
//  CustomViews.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 16.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class ColorView: NSView {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.wantsLayer = true
    let layer = CALayer()
    layer.masksToBounds = true
    layer.cornerRadius = 5.5
    layer.borderWidth = 0.5
    layer.borderColor = ColorView.sharedBorderColor.cgColor
    self.layer = layer
  }
  
  override func layout() {
    if let layer = self.layer {
      //change border color after system theme changed
      layer.borderColor = ColorView.sharedBorderColor.cgColor
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
}


class HeaderView: NSView {
  var trackingArea: NSTrackingArea? = nil
  weak var button : NSButton?

  override func updateTrackingAreas() {
    if let ta = trackingArea {
      self.removeTrackingArea(ta)
    }

    let opts: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
    trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self)

    self.addTrackingArea(trackingArea!)
  }

  open override func mouseEntered(with theEvent: NSEvent) {
    if button?.title == "Hide" {
      button?.isHidden = false
    }
  }

  open override func mouseExited(with event: NSEvent) {
    if button?.title == "Hide" {
      button?.isHidden = true
    }
  }
}

class PaddedTextFieldCell: NSTextFieldCell {
  @IBInspectable var rightPadding: CGFloat = 5.0
  
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
      let rectInset = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width + rightPadding, rect.size.height)
      return super.drawingRect(forBounds: rectInset)
    }
}
