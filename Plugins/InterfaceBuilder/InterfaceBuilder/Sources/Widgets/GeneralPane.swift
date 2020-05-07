//
//  GeneralPane.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 14.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import ScadeKit
import NimbleCore

class GeneralPane: NSViewController {
  @IBOutlet weak var visibilityButton: NSButton?
  @IBOutlet weak var headerView: HeaderView?
  
  @IBOutlet weak var contentView: NSStackView?
  
  @IBOutlet weak var nameTextField: NSTextField?
  
  @IBOutlet weak var accessibillityView: NSView?
  @IBOutlet weak var accessibillityTextField: NSTextField?
  
  @IBOutlet weak var textView: NSView?
  @IBOutlet weak var textTextField: NSTextField?
  
  @IBOutlet weak var enableCheckbox: NSButton?
  @IBOutlet weak var visibleСheckbox: NSButton?
  @IBOutlet weak var wrapTextСheckbox: NSButton?
  
  private weak var shownWidget: SCDWidgetsWidget?

  weak var document: Document? = nil
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.textTextField?.delegate = self
    visibilityButton?.isHidden = true
    headerView?.button = visibilityButton
  }
  
  
  private func setFields(widget: SCDWidgetsWidget) {
    nameTextField?.stringValue = widget.name
    
    if let drawing = widget.drawing {
      accessibillityView?.isHidden = false
      accessibillityTextField?.stringValue = drawing.accessibilityLabel
    } else {
      accessibillityView?.isHidden = true
    }
    
    if let textWidget = widget as? SCDWidgetsTextWidget {
      textView?.isHidden = false
      wrapTextСheckbox?.isHidden = false
      textTextField?.stringValue = textWidget.text
      wrapTextСheckbox?.state = textWidget.isWrapText ? .on : .off
    } else {
      textView?.isHidden = true
      wrapTextСheckbox?.isHidden = true
    }
    
    enableCheckbox?.state = widget.isEnable ? .on : .off
    visibleСheckbox?.state = widget.isVisible ? .on : .off
  }
  
  // MARK: - UI actions
  @IBAction func hideButtonDidClick(_ sender: Any) {
    guard let contentView = contentView,
      let visabilityButton = visibilityButton
      else { return }
    
    contentView.isHidden = !contentView.isHidden
    
    visabilityButton.title = contentView.isHidden ? "Show" : "Hide"
    visabilityButton.isHidden = !contentView.isHidden
  }
  
  @IBAction func nameDidChange(_ sender: Any?) {
    guard let value = nameTextField?.stringValue,
          let widget = widget
    else { return }

    if widget.name != value {
      widget.name = value
      documentDidChange()
    }
  }
  
  @IBAction func accessibilityDidChange(_ sender: Any) {
    guard accessibillityView?.isHidden == false,
          let value = accessibillityTextField?.stringValue,
          let drawing = widget?.drawing
    else { return }
    
    if drawing.accessibilityLabel != value {
      drawing.accessibilityLabel = value
      documentDidChange()
    }
  }
  
  @IBAction func textDidChange(_ sender: Any) {
    guard textView?.isHidden == false,
          let value = textTextField?.stringValue,
          let textWidget = widget as? SCDWidgetsTextWidget
    else { return }
    
    if textWidget.text != value {
      textWidget.text = value
      documentDidChange()
    }
  }
  
  @IBAction func enableDidChange(_ sender: Any) {
    guard let value = enableCheckbox?.state else { return }
    
    widget?.isEnable = value == .on
    documentDidChange()
  }
  
  @IBAction func visibleDidChange(_ sender: Any) {
    guard let value = visibleСheckbox?.state else { return }  
    
    widget?.isVisible = value == .on
    documentDidChange()
  }
  
  @IBAction func wrapTextDidChange(_ sender: Any) {
    guard wrapTextСheckbox?.isHidden == false, let value = wrapTextСheckbox?.state, let textWidget = widget as? SCDWidgetsTextWidget else { return }
    
    textWidget.isWrapText = value == .on
    documentDidChange()
  }

  private func documentDidChange() {
    document?.updateChangeCount(.changeDone)
  }
}

extension GeneralPane: EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget?) {
    if let widget = widget {
      self.view.isHidden = false
      self.widget = widget
    } else {
      self.view.isHidden = true
    }
  }
}

extension GeneralPane : NSTextFieldDelegate {
  func controlTextDidChange(_ notification: Notification) {
    guard let textField  = notification.object as? NSTextField else { return }
    if textField === textTextField {
      textDidChange(textField)
    }
  }
}

