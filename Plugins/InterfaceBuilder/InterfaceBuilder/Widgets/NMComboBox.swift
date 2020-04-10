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
  
  var textDidChange: ((String) -> Void)?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    let layer = CALayer()
    layer.cornerRadius = 5.0
    layer.masksToBounds = true
    self.layer = layer
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
    textDidChange?(textField?.stringValue ?? "")
  }
  
  @IBAction func textDidEdit(_ sender: Any) {
    textDidChange?(textField?.stringValue ?? "")
  }
  
  @IBAction func buttonDidClick(_ sender: Any) {
    buttonMenu?.popUp(positioning: buttonMenu?.item(at: 0), at: NSEvent.mouseLocation, in: nil)
  }
}
