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
    guard let value = nameTextField?.stringValue else { return }
    
    widget?.name = value
  }
  
  @IBAction func accessibilityDidChange(_ sender: Any) {
    guard accessibillityView?.isHidden == false, let value = accessibillityTextField?.stringValue, let drawing = widget?.drawing else { return }
    
    drawing.accessibilityLabel = value
  }
  
  @IBAction func textDidChange(_ sender: Any) {
    guard textView?.isHidden == false, let value = textTextField?.stringValue, let textWidget = widget as? SCDWidgetsTextWidget else { return }
    
    textWidget.text = value
  }
  
  @IBAction func enableDidChange(_ sender: Any) {
    guard let value = enableCheckbox?.state else { return }
    
    widget?.isEnable = value == .on
  }
  
  @IBAction func visibleDidChange(_ sender: Any) {
    guard let value = visibleСheckbox?.state else { return }
    
    widget?.isVisible = value == .on
  }
  
  @IBAction func wrapTextDidChange(_ sender: Any) {
    guard wrapTextСheckbox?.isHidden == false, let value = wrapTextСheckbox?.state, let textWidget = widget as? SCDWidgetsTextWidget else { return }
    
    textWidget.isWrapText = value == .on
  }
}

extension GeneralPane: EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget) {
    self.view.isHidden = false
    self.widget = widget
  }
}
