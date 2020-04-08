//
//  TextPane.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 07.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import ScadeKit

class TextPane: NSViewController {
  
  @IBOutlet weak var paneTitle: NSTextField?
  @IBOutlet weak var visabilityButton: NSButton?
  
  @IBOutlet weak var headerView: HeaderView?
  @IBOutlet weak var contentView: NSView?
  
  @IBOutlet weak var titleTextField: NSTextField?
  
  @IBOutlet weak var familyPopUpButton: NSPopUpButton?
  @IBOutlet weak var stylePopUpButton: NSPopUpButton?
  @IBOutlet weak var sizeTextField: NSTextField?
  @IBOutlet weak var sizeStepper: NSStepper?
  
  private weak var shownWidget: SCDWidgetsWidget?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for family in NSFontManager.shared.availableFontFamilies {
      familyPopUpButton?.addItem(withTitle: family)
    }
    
    visabilityButton?.isHidden = true
    headerView?.button = visabilityButton
    
    sizeTextField?.intValue = 13
    sizeStepper?.intValue = sizeTextField?.intValue ?? 0
  }
  
  var widget: SCDWidgetsWidget? {
    set {
      guard let newWidget = newValue else {
        shownWidget = nil
        return
      }
      setFields(widget: newWidget)
      shownWidget = newWidget
    }
    get {
      shownWidget
    }
  }
  
 
  private func setFields(widget: SCDWidgetsWidget) {
    titleTextField?.stringValue = widget.name
  }
  
  @IBAction func buttonDidClick(_ sender: Any) {
    guard let contentView = contentView,
      let visabilityButton = visabilityButton
      else { return }
    
    contentView.isHidden = !contentView.isHidden
    
    visabilityButton.title = contentView.isHidden ? "Show" : "Hide"
    visabilityButton.isHidden = !contentView.isHidden
  }
  
  @IBAction func stepperDidClick(_ sender: Any) {
    sizeTextField?.intValue = sizeStepper?.intValue ?? 0
  }
  
  @IBAction func sizeDidChange(_ sender: Any) {
    sizeStepper?.intValue = sizeTextField?.intValue ?? 0
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

