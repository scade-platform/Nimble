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
  
  @IBOutlet weak var familyPopUpButton: NSPopUpButton?
  @IBOutlet weak var stylePopUpButton: NSPopUpButton?
  @IBOutlet weak var sizeComboBoxView: NSView?
  
  private weak var shownWidget: SCDWidgetsWidget?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for family in NSFontManager.shared.availableFontFamilies {
      familyPopUpButton?.addItem(withTitle: family)
    }
    
    visabilityButton?.isHidden = true
    headerView?.button = visabilityButton
    
 
    
    let nmComboBox = NMComboBox.loadFromNib()
    nmComboBox.textField?.stringValue = "11"
    sizeComboBoxView?.addSubview(nmComboBox)
    nmComboBox.layout(into: sizeComboBoxView!)
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
  }
  
  @IBAction func buttonDidClick(_ sender: Any) {
    guard let contentView = contentView,
      let visabilityButton = visabilityButton
      else { return }
    
    contentView.isHidden = !contentView.isHidden
    
    visabilityButton.title = contentView.isHidden ? "Show" : "Hide"
    visabilityButton.isHidden = !contentView.isHidden
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

fileprivate extension NSView {
  func layout(into: NSView, insets: NSEdgeInsets = NSEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(equalTo: into.topAnchor, constant: insets.top).isActive = true
    self.bottomAnchor.constraint(equalTo: into.bottomAnchor, constant: -insets.bottom).isActive = true
    self.leadingAnchor.constraint(equalTo: into.leadingAnchor, constant: insets.left).isActive = true
    self.trailingAnchor.constraint(equalTo: into.trailingAnchor, constant: -insets.right).isActive = true
  }
}
