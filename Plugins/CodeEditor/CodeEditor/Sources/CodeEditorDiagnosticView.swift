//
//  CodeEditorDiagnosticView.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 18.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


class CodeEditorDiagnosticView: NSTableView {
  
  override var acceptsFirstResponder: Bool { return false }
  
  let iconColumn = NSTableColumn()
  let textColumn = NSTableColumn()
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    self.layer = CALayer()
    self.layer?.cornerRadius = 6.0
    self.layer?.masksToBounds = true
    
    self.gridColor = .clear
    self.intercellSpacing = NSMakeSize(0.0, 0.0)
    self.selectionHighlightStyle = .none
    self.focusRingType = .none
    self.translatesAutoresizingMaskIntoConstraints = false
    
    iconColumn.width = 20
    textColumn.width = 100
        
    self.addTableColumn(iconColumn)
    self.addTableColumn(textColumn)
    
    self.delegate = self
    self.dataSource = self
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    guard let superview = superview else { return }
    let width = tableColumns.reduce(0){$0 + $1.width}
      
    widthAnchor.constraint(equalToConstant: width).isActive = true
    rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    topAnchor.constraint(equalTo: superview.topAnchor, constant: 20).isActive = true
  }
}


extension CodeEditorDiagnosticView: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return 3
  }
}


extension CodeEditorDiagnosticView: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var cellView: NSView? = nil
    
    if tableColumn === iconColumn {
      cellView = NSView()
      cellView?.setBackgroundColor(NSColor(colorCode: "#863836")!)
    } else {
      cellView = NSTextField(labelWithString: "Test")
      cellView?.setBackgroundColor(NSColor(colorCode: "#423336")!)
    }
    
    return cellView
  }
    
}



