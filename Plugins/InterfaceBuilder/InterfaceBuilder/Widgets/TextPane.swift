//
//  TextPane.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 07.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import ScadeKit
import NimbleCore

class TextPane: NSViewController {
  
  @IBOutlet weak var paneTitle: NSTextField?
  @IBOutlet weak var visibilityButton: NSButton?
  
  @IBOutlet weak var headerView: HeaderView?
  @IBOutlet weak var contentView: NSView?
  
  @IBOutlet weak var familyPopUpButton: NSPopUpButton?
  @IBOutlet weak var stylePopUpButton: NSPopUpButton?
  @IBOutlet weak var sizeTextField: NSTextField?
  @IBOutlet weak var sizeStepper: NSStepper?
  
  @IBOutlet weak var colorWell: NSColorWell?
  
  
  private weak var shownWidget: TextWidget?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    for family in NSFontManager.shared.availableFontFamilies {
      familyPopUpButton?.addItem(withTitle: family)
    }
    
    visibilityButton?.isHidden = true
    headerView?.button = visibilityButton
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
    
    colorWell?.color = font.color.nsColor
    sizeTextField?.stringValue = "\(font.size)"
    sizeStepper?.intValue = Int32(font.size)
  }
  
  @IBAction func hideButtonDidClick(_ sender: Any) {
    guard let contentView = contentView,
      let visabilityButton = visibilityButton
      else { return }
    
    contentView.isHidden = !contentView.isHidden
    
    visabilityButton.title = contentView.isHidden ? "Show" : "Hide"
    visabilityButton.isHidden = !contentView.isHidden
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
  
  @IBAction func sizeTextDidChange(_ sender: Any) {
    guard let value = sizeTextField?.intValue, let font = widget?.font else { return }
    font.size = Int(value)
    sizeStepper?.intValue = value
  }
  
  @IBAction func sizeStepperDidClick(_ sender: Any) {
    guard let value = sizeStepper?.intValue, let font = widget?.font else { return }
    font.size = Int(value)
    sizeTextField?.intValue = value
  }
  
  @IBAction func colorDidChange(_ sender: Any) {
    guard let value = colorWell?.color, let font = widget?.font else { return }
    
    font.color = value.scdGraphicsRGB
  }
}



extension TextPane : EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget) {
    switch widget {
    case is SCDWidgetsTextWidget:
      let textWidget = widget as! TextWidget
      self.view.isHidden = false
      self.widget = textWidget
    default:
      self.view.isHidden = true
    }
  }
}


extension SCDGraphicsRGB {
  var nsColor: NSColor {
    NSColor(red: CGFloat(self.red) / 255, green: CGFloat(self.green) / 255, blue: CGFloat(self.blue) / 255, alpha: CGFloat(self.alpha) / 255)
  }
}

extension NSColor {
  var scdGraphicsRGB : SCDGraphicsRGB {
    return SCDGraphicsRGB(red: Int(self.redComponent * 255), green: Int(self.greenComponent * 255), blue: Int(self.blueComponent * 255), alpha: Int(self.alphaComponent * 255))
  }
}

protocol TextWidget: class {
  var font: SCDGraphicsFont? { get set }
}

extension SCDWidgetsTextWidget: TextWidget {}
