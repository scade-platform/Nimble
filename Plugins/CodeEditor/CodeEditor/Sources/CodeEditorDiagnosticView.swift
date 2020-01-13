//
//  CodeEditorDiagnosticView.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 18.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor
import NimbleCore


class CodeEditorDiagnosticView: NSTableView {
  
  let diagnostic: Diagnostic
  
  
  //TODO: colores should be moved to themes
  // these colors for dark theme
  private lazy var iconColumnColor : NSColor = {
    switch diagnostic.severity {
    case .error:
      return NSColor(colorCode: "#853332")!
    case .warning:
      return NSColor(colorCode: "#907723")!
    default:
      return NSColor(colorCode: "#c9ccc8")!
    }
  }()
  
  //TODO: colores should be moved to themes
  // these colors for dark theme
  private lazy var textColumnColor : NSColor = {
    switch diagnostic.severity {
    case .error:
      return NSColor(colorCode: "#382829")!
    case .warning:
      return NSColor(colorCode: "#382829")!
    default:
      return NSColor(colorCode: "#e7eae6")!
    }
  }()

  
  let iconColumn = NSTableColumn()
  let textColumn = NSTableColumn()
  
  init(diagnostic: Diagnostic) {
    self.diagnostic = diagnostic
    super.init(frame: .zero)
    
    self.layer = CALayer()
    self.layer?.cornerRadius = 6.0
    self.layer?.masksToBounds = true
    
    self.gridColor = .clear
    self.intercellSpacing = NSMakeSize(0.0, 0.0)
    self.selectionHighlightStyle = .none
    self.focusRingType = .none
    self.translatesAutoresizingMaskIntoConstraints = false
    
    iconColumn.width = 20
    textColumn.width = 120
    
    self.addTableColumn(iconColumn)
    self.addTableColumn(textColumn)
    
    self.delegate = self
    self.dataSource = self
  }
  
  //we don't use storyboard for this view
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    guard let superview = superview else { return }
    let width = tableColumns.reduce(0){$0 + $1.width}
    
    widthAnchor.constraint(equalToConstant: width).isActive = true
    rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    if diagnostic.severity == .warning {
      topAnchor.constraint(equalTo: superview.topAnchor, constant: 20).isActive = true
    } else {
      topAnchor.constraint(equalTo: superview.topAnchor, constant: 100).isActive = true
    }
    
  }
}


extension CodeEditorDiagnosticView: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return diagnostic.message.numberOfLines
  }
}


extension CodeEditorDiagnosticView: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//    guard let k = tableColumn else {}
    var cellView: NSView?
    if tableColumn === iconColumn {
      let imgView = NSImageView()
      imgView.imageScaling = .scaleProportionallyUpOrDown
      var img: NSImage?
      switch diagnostic.severity {
      case .warning:
        img = Bundle(for: type(of: self)).image(forResource: "warning")?.imageWithTint(.black)
      case .error:
        img = Bundle(for: type(of: self)).image(forResource: "error")?.imageWithTint(.black)
      default:
        break
      }
      imgView.image = img
      imgView.imageScaling = .scaleProportionallyUpOrDown
      let parentView = NSView()
      parentView.setBackgroundColor(iconColumnColor)
      parentView.addSubview(imgView)
      imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
      cellView = parentView
    } else {
      let textField = NSTextField(labelWithString: diagnostic.message)
      if let font = NSFont.init(name: "SFMono-Medium", size: 12) {
        textField.font = font
      }
      textField.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
      textField.sizeToFit()
      textField.drawsBackground = true
      textField.backgroundColor = textColumnColor
      cellView = textField
    }
    
    return cellView
  }
  
}


extension NSImage {
    internal func imageWithTint(_ tint: NSColor) -> NSImage {
        var imageRect = NSZeroRect;
        imageRect.size = self.size;
        
        let highlightImage = NSImage(size: imageRect.size)
        
        highlightImage.lockFocus()
        
        self.draw(in: imageRect, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        
        tint.set()
        imageRect.fill(using: .sourceAtop);
        
        highlightImage.unlockFocus()
        
        return highlightImage;
    }
}


extension NSView {
  func layout(into: NSView, insets: NSEdgeInsets = NSEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(equalTo: into.topAnchor, constant: insets.top).isActive = true
    self.bottomAnchor.constraint(equalTo: into.bottomAnchor, constant: -insets.bottom).isActive = true
    self.leadingAnchor.constraint(equalTo: into.leadingAnchor, constant: insets.left).isActive = true
    self.trailingAnchor.constraint(equalTo: into.trailingAnchor, constant: -insets.right).isActive = true
  }
}
