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
  
  @IBOutlet weak var alignmentSegmentedControl: NSSegmentedControl?
  @IBOutlet weak var baselineSegmentedControl: NSSegmentedControl?

  weak var document: Document? = nil
  
  private weak var shownWidget: SCDWidgetsTextWidget?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.sizeTextField?.delegate = self
    
    for family in WidgetFonts.shared.supportedFontFamilies {
      familyPopUpButton?.addItem(withTitle: family)
    }
    
    visibilityButton?.isHidden = true
    headerView?.button = visibilityButton
    
    let arrowUp = InspectorIcons.arrowUp.image
    arrowUp.isTemplate = true
    baselineSegmentedControl?.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 0)
    baselineSegmentedControl?.setImage(arrowUp, forSegment: 0)
    
    
    let arrowUpDown = InspectorIcons.arrowUpDown.image
    arrowUpDown.isTemplate = true
    baselineSegmentedControl?.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 1)
    baselineSegmentedControl?.setImage(arrowUpDown, forSegment: 1)
    
    
    let arrowDown = InspectorIcons.arrowDown.image
    arrowDown.isTemplate = true
    baselineSegmentedControl?.setImageScaling(.scaleProportionallyUpOrDown, forSegment: 2)
    baselineSegmentedControl?.setImage(arrowDown, forSegment: 2)
  }
  
  var widget: SCDWidgetsTextWidget? {
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
  
  private func setFields(widget: SCDWidgetsTextWidget) {
    if widget.font == nil {
      let font = SCDGraphicsFont()
      font.fontFamily = "ArialMT"
      font.size = 17
      widget.font = font
    }

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
    
    switch widget.horizontalAlignment {
    case SCDLayoutHorizontalAlignment.left:
      alignmentSegmentedControl?.setSelected(true, forSegment: 0)
    case SCDLayoutHorizontalAlignment.center:
      alignmentSegmentedControl?.setSelected(true, forSegment: 1)
    case SCDLayoutHorizontalAlignment.right:
      alignmentSegmentedControl?.setSelected(true, forSegment: 2)
    default:
      break
    }
    
    switch widget.baselineAlignment {
    case SCDWidgetsBaselineAlignment.alphabetic:
      baselineSegmentedControl?.setSelected(true, forSegment: 0)
    case SCDWidgetsBaselineAlignment.middle:
      baselineSegmentedControl?.setSelected(true, forSegment: 1)
    case SCDWidgetsBaselineAlignment.hanging:
      baselineSegmentedControl?.setSelected(true, forSegment: 2)
    default:
      break
    }
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
    documentDidChange()
    
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
          if let styledFont = NSFont(name: availableFont[0] as! String, size: CGFloat(font.size)) {
            font.fontFamily = styledFont.fontName
            documentDidChange()
          }
        }
      }
    }
  }
  
  @IBAction func sizeTextDidChange(_ sender: Any) {
    guard let value = sizeTextField?.intValue, let font = widget?.font else { return }
    font.size = Int(value)
    sizeStepper?.intValue = value
    documentDidChange()
  }
  
  @IBAction func sizeStepperDidClick(_ sender: Any) {
    guard let value = sizeStepper?.intValue, let font = widget?.font else { return }
    font.size = Int(value)
    sizeTextField?.intValue = value
    documentDidChange()
  }
  
  @IBAction func colorDidChange(_ sender: Any) {
    guard let value = colorWell?.color, let font = widget?.font else { return }
    
    font.color = value.scdGraphicsRGB
    documentDidChange()
  }
  
  @IBAction func alignmentDidChange(_ sender: Any) {
    guard let value = alignmentSegmentedControl?.selectedSegment, let textWidget = widget else { return }
    switch value {
    case 0:
      textWidget.horizontalAlignment = .left
    case 1:
      textWidget.horizontalAlignment = .center
    case 2:
      textWidget.horizontalAlignment = .right
    default:
      return
    }
    documentDidChange()
  }
  
  @IBAction func baselineDidChange(_ sender: Any) {
    guard let value = baselineSegmentedControl?.selectedSegment, let textWidget = widget else { return }
    
    switch value {
    case 0:
      textWidget.baselineAlignment = .alphabetic
    case 1:
      textWidget.baselineAlignment = .middle
    case 2:
      textWidget.baselineAlignment = .hanging
    default:
      return
    }
    documentDidChange()
  }

  private func documentDidChange() {
    if let editorView = document?.editor as? EditorView {
      editorView.updateSelector()
      
    }
    document?.updateChangeCount(.changeDone)
  }
}



extension TextPane : EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget?) {
    switch widget {
    case is SCDWidgetsTextWidget:
      let textWidget = widget as! SCDWidgetsTextWidget
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

extension TextPane : NSTextFieldDelegate {
  func controlTextDidChange(_ notification: Notification) {
    guard let textField  = notification.object as? NSTextField else { return }
    if textField === sizeTextField {
      sizeTextDidChange(textField)
    }
  }
}
