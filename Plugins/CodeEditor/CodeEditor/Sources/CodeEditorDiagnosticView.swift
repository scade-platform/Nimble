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
        img = Bundle(for: type(of: self)).image(forResource: "warning")?.imageWithTint(NSColor(colorCode: "#f1ba01")!)
      default:
        break
      }
      imgView.image = img
      //TODO: Improve it to show an image with background color
      //To see image you should comment next line
      imgView.setBackgroundColor(iconColumnColor)
      cellView = imgView
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
