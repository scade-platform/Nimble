//
//  NMComboBox.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 09.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

class NMComboBox: NSView {
  @IBOutlet weak var textField: NSTextField?
  @IBOutlet weak var button: NSButton?
  var buttonMenu: NSMenu?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.drawPageBorder(with: NSSize(width: 1, height: 1))
  }
  
  override func viewDidMoveToWindow() {
    self.buttonMenu = NSMenu()
    ["9", "10", "11", "12", "13", "14", "18", "24", "36", "48", "64", "72", "96", "144", "288"].forEach{addMenuItem(title: $0)}
  }
  
  private func addMenuItem(title: String) {
    let item = NSMenuItem(title: title, action: #selector(itemDidSelect(_:)), keyEquivalent: "")
    item.target = self
    self.buttonMenu?.addItem(item)
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }
  
  @objc func itemDidSelect(_ sender: Any?) {
    guard let item = sender as? NSMenuItem else {return}
    textField?.stringValue = item.title
  }
  
  @IBAction func buttonDidClick(_ sender: Any) {
    buttonMenu?.popUp(positioning: buttonMenu?.item(at: 0), at: NSEvent.mouseLocation, in: nil)
  }
  
}

class TextFieldCell : NSTextField {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.invalidateIntrinsicContentSize()
  }
  
  override var intrinsicContentSize: NSSize {
    // Guard the cell exists and wraps
    guard let cell = self.cell, cell.wraps else {return super.intrinsicContentSize}

    // Use intrinsic width to jive with autolayout
    let width = super.intrinsicContentSize.width / 2

    return NSMakeSize(width, super.intrinsicContentSize.height);
  }
}
