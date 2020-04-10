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
  weak var nmComboBox : NMComboBox?
  
  @IBOutlet weak var colorPicker: NSColorWell?
  
  
  private weak var shownWidget: TextWidget?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for family in NSFontManager.shared.availableFontFamilies {
      familyPopUpButton?.addItem(withTitle: family)
    }
    
    visabilityButton?.isHidden = true
    headerView?.button = visabilityButton
    
 
    let nmComboBox = NMComboBox.loadFromNib()
    sizeComboBoxView?.addSubview(nmComboBox)
    nmComboBox.layout(into: sizeComboBoxView!)
    self.nmComboBox = nmComboBox
    nmComboBox.textDidChange = sizeDidChange(_:)
  }
  
  var widget: TextWidget? {
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
 
  private func setFields(widget: TextWidget) {
    guard let font = widget.font else { return }
    if let currentFont = NSFont(name: font.fontFamily, size: CGFloat(font.size)) {
      let familyName = currentFont.familyName
      familyPopUpButton?.selectItem(withTitle: familyName!)
      if let availableFonts = NSFontManager.shared.availableMembers(ofFontFamily: familyName!) {
        for availableFont in availableFonts {
          stylePopUpButton?.addItem(withTitle: availableFont[1] as! String)
          if availableFont[0] as! String == font.fontFamily {
            stylePopUpButton?.selectItem(withTitle: availableFont[1] as! String)
          }
        }
      }
    }
    colorPicker?.color = font.color.nsColor
    colorPicker?.layout()
    nmComboBox?.textField?.stringValue = "\(font.size)"
  }
  
  @IBAction func buttonDidClick(_ sender: Any) {
    guard let contentView = contentView,
      let visabilityButton = visabilityButton
      else { return }
    
    contentView.isHidden = !contentView.isHidden
    
    visabilityButton.title = contentView.isHidden ? "Show" : "Hide"
    visabilityButton.isHidden = !contentView.isHidden
  }
  
  func sizeDidChange(_ newValue: String) {
    guard let intValue = Int(newValue),
      let font = widget?.font
    else { return }
    
    font.size = intValue
  }
  
  @IBAction func fontDidChange(_ sender: Any) {
    guard let font = widget?.font,
      let selectedFont = familyPopUpButton?.selectedItem?.title
    else { return }
    
    font.fontFamily = selectedFont
    
    stylePopUpButton?.removeAllItems()
    if let availableFonts = NSFontManager.shared.availableMembers(ofFontFamily: selectedFont) {
      for font in availableFonts {
        stylePopUpButton?.addItem(withTitle: font[1] as! String)
      }
    }
   
    
  }
  
  @IBAction func styleDidChange(_ sender: Any) {
    guard let font = widget?.font,
      let selectedStyle = stylePopUpButton?.selectedItem?.title,
      let selectedFont = familyPopUpButton?.selectedItem?.title
    else { return }
    if let availableFonts = NSFontManager.shared.availableMembers(ofFontFamily: selectedFont) {
      for availableFont in availableFonts {
        if availableFont[1] as! String == selectedStyle {
          let styledFont = NSFont(name: availableFont[0] as! String, size: CGFloat(font.size))
          font.fontFamily = styledFont!.fontName
        }
      }
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

extension TextPane : EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget) {
    switch widget {
    case is SCDWidgetsLabel,
         is SCDWidgetsTextbox,
         is SCDWidgetsButton:
      let textWidget = widget as! TextWidget
      self.view.isHidden = false
      self.widget = textWidget
    default:
      self.view.isHidden = true
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

extension SCDGraphicsRGB {
  var nsColor: NSColor {
    NSColor(red: CGFloat(self.red) / 255, green: CGFloat(self.green) / 255, blue: CGFloat(self.blue) / 255, alpha: CGFloat(self.alpha))
  }
}

protocol TextWidget: class {
  var font: SCDGraphicsFont? { get set }
}

extension SCDWidgetsLabel: TextWidget {}
extension SCDWidgetsButton: TextWidget {}
extension SCDWidgetsTextbox: TextWidget {}
