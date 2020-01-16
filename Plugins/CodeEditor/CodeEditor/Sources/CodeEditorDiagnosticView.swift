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


class CodeEditorDiagnosticView {
  
  private(set) var diagnostics: [Diagnostic] = []
  
  private lazy var errors : [Diagnostic] = {
    return diagnostics.filter{$0.severity == .error}
  }()
  
  private lazy var warnings : [Diagnostic] = {
    return diagnostics.filter{$0.severity == .warning}
  }()
  
  //  var isCollapsed: Bool {
  //    didSet {
  //      if isCollapsed {
  //        currentDelegate = CollapsedCodeEditorDiagnosticViewDelegate(diagnostics: diagnostics, iconColumn: iconColumn, textColumn: textColumn)
  //      } else {
  //        currentDelegate = ExpandedCodeEditorDiagnosticViewDelegate(diagnostics: diagnostics, iconColumn: iconColumn, textColumn: textColumn)
  //      }
  //      updateDelegate()
  //    }
  //  }
  //
  var view: NSStackView
  
  func mouseDownHandler(_ view: NSView) {
    (view as? NSStackView)?.arrangedSubviews.forEach{$0.isHidden = !$0.isHidden}
  }
  
  @objc func mouseDownHandler2() {
    self.view.arrangedSubviews.forEach{$0.isHidden = !$0.isHidden}
  }
  
  init(diagnostics: [Diagnostic]) {
    self.diagnostics.append(contentsOf: diagnostics)
    self.view = NSStackView()
    self.view.orientation = .vertical
    self.view.alignment = .trailing
    self.view.distribution = .fillEqually

    
    let collapsedTableView = TableDiagnosticView(diagnostics: diagnostics, delegateType: CollapsedTableDiagnosticViewDelegate.self)
    collapsedTableView.mouseDownCallBack = mouseDownHandler
    self.view.addArrangedSubview(collapsedTableView)
//    self.view.translatesAutoresizingMaskIntoConstraints = false
    collapsedTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    collapsedTableView.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor).isActive = true
    if !errors.isEmpty {
      let errorsTableView = TableDiagnosticView(diagnostics: errors, delegateType: ExpandedTableDiagnosticViewDelegate.self)
      errorsTableView.isHidden = true
      errorsTableView.mouseDownCallBack = mouseDownHandler

      self.view.addArrangedSubview(errorsTableView)
      errorsTableView.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor).isActive = true
      errorsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    if !warnings.isEmpty {
      let warningsTableView = TableDiagnosticView(diagnostics: warnings, delegateType: ExpandedTableDiagnosticViewDelegate.self)
      warningsTableView.isHidden = true
      warningsTableView.mouseDownCallBack = mouseDownHandler
      self.view.addArrangedSubview(warningsTableView)
      warningsTableView.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor).isActive = true
      warningsTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
  }
  
}

private class TableDiagnosticView: NSTableView {
  private(set) var diagnostics: [Diagnostic] = []
  
  var mouseDownCallBack: ((NSView) -> Void)?
  
  let iconColumn = NSTableColumn()
  let textColumn = NSTableColumn()
  
  let tableDelegate : TableDiagnosticViewDelegate
  
  var widthConstraint: NSLayoutConstraint?
  
  init(diagnostics: [Diagnostic], delegateType: TableDiagnosticViewDelegate.Type) {
    self.diagnostics.append(contentsOf: diagnostics)
    self.tableDelegate = delegateType.init(diagnostics: diagnostics, iconColumn: iconColumn, textColumn: textColumn)
    super.init(frame: .zero)
    
    self.layer = CALayer()
    self.layer?.cornerRadius = 6.0
    self.layer?.masksToBounds = true
    
    self.gridColor = .clear
    self.intercellSpacing = NSMakeSize(0.0, 0.0)
    self.selectionHighlightStyle = .none
    self.focusRingType = .none
    self.translatesAutoresizingMaskIntoConstraints = false
//    self.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
    
//    iconColumn.width = 50
//    iconColumn.resizingMask = .autoresizingMask
//    textColumn.width = 200
    
    self.addTableColumn(iconColumn)
    self.addTableColumn(textColumn)
    
    
    self.delegate = tableDelegate
    self.dataSource = tableDelegate
    
  }
  
  //we don't use storyboard for this view
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
//    guard let superview = superview else { return }
    let width = tableColumns.reduce(0){$0 + $1.width}
    self.translatesAutoresizingMaskIntoConstraints = false
    if widthConstraint == nil {
      widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
      widthConstraint?.isActive = true
      return
    }
    widthConstraint?.constant = width
//    rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    //TODO: set right position
//    topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
  }
  
  override func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    mouseDownCallBack?(self.superview!)
  }
}

private class TableDiagnosticViewDelegate : NSObject, NSTableViewDataSource, NSTableViewDelegate {
  let diagnostics: [Diagnostic]
  let iconColumn : NSTableColumn
  let textColumn : NSTableColumn
  
  required init(diagnostics: [Diagnostic], iconColumn: NSTableColumn, textColumn: NSTableColumn) {
    self.diagnostics = diagnostics
    self.iconColumn = iconColumn
    self.textColumn = textColumn
  }
  
  //TODO: colores should be moved to themes
  // these colors for dark theme
  fileprivate func iconColumnColor(for diagnostic: Diagnostic) -> NSColor {
    switch diagnostic.severity {
    case .error:
      return NSColor(colorCode: "#853332")!
    case .warning:
      return NSColor(colorCode: "#907723")!
    default:
      return NSColor(colorCode: "#c9ccc8")!
    }
  }
  
  //TODO: colores should be moved to themes
  // these colors for dark theme
  fileprivate func textColumnColor(for diagnostic: Diagnostic) -> NSColor {
    switch diagnostic.severity {
    case .error:
      return NSColor(colorCode: "#382829")!
    case .warning:
      return NSColor(colorCode: "#382829")!
    default:
      return NSColor(colorCode: "#e7eae6")!
    }
  }
  
  fileprivate func icon(for diagnostic: Diagnostic) -> NSImage? {
    switch diagnostic.severity {
    case .warning:
      return Bundle(for: type(of: self)).image(forResource: "warning")
    case .error:
      return Bundle(for: type(of: self)).image(forResource: "error")
    default:
      return nil
    }
  }
  
  func stringWidth(for diagnostic: Diagnostic) -> CGFloat? {
    let font = NSFont.init(name: "SFMono-Medium", size: 12) ?? NSFont.systemFont(ofSize: 12)
    let atrStr = NSAttributedString(string: diagnostic.message, attributes: [NSAttributedString.Key.font : font])
    return atrStr.size().width
  }
}

private class CollapsedTableDiagnosticViewDelegate : TableDiagnosticViewDelegate {
  
  lazy var currentIconColumnColor: NSColor? = {
    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      return iconColumnColor(for: diagnostic)
    }
    return nil
  }()
  
  
  
  required init(diagnostics: [Diagnostic], iconColumn: NSTableColumn, textColumn: NSTableColumn) {
    super.init(diagnostics: diagnostics, iconColumn: iconColumn, textColumn: textColumn)
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var cellView: NSView?
    if tableColumn == iconColumn {
      cellView = NSView()
      let stackView = NSStackView()
      stackView.orientation = .horizontal
      stackView.distribution = .equalSpacing
      stackView.spacing = 0
      var width = 0
      if diagnostics.count > 1 {
        let countView = NSTextField(labelWithString: "\(diagnostics.count)")
        if let font = NSFont.init(name: "SFMono-Medium", size: 12) {
          countView.font = font
        }
        countView.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
        countView.sizeToFit()
        countView.alignment = .center
        countView.drawsBackground = true
        countView.backgroundColor = currentIconColumnColor
        countView.translatesAutoresizingMaskIntoConstraints = false
//        countView.heightAnchor.constraint(equalToConstant: iconColumn.tableView?.rowHeight ?? 17).isActive = true
        stackView.addArrangedSubview(countView)
        width = Int(countView.bounds.width) + 5
      }
      for diagnosticType in DiagnosticSeverity.allCases {
        guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
        let imgView = NSImageView()
        imgView.imageScaling = .scaleProportionallyUpOrDown
        imgView.image = icon(for: diagnostic)?.imageWithTint(.black)
        let parentView = NSView()
        parentView.setBackgroundColor(currentIconColumnColor!)
        parentView.addSubview(imgView)
        imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 0, bottom: 3, right: 0))
        imgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(parentView)
        width = width + 20
      }
      dump(width)
      iconColumn.width = CGFloat(width)
      cellView?.setBackgroundColor(currentIconColumnColor!)
      cellView?.addSubview(stackView)
      stackView.layout(into: cellView!)
    } else {
      cellView = NSView()
      for diagnosticType in DiagnosticSeverity.allCases {
        guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
        let textField = NSTextField(labelWithString: diagnostic.message)
        if let font = NSFont.init(name: "SFMono-Medium", size: 12) {
          textField.font = font
        }
        textField.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
        textField.sizeToFit()
        textField.drawsBackground = true
        textField.backgroundColor = textColumnColor(for: diagnostic)
        cellView?.setBackgroundColor(textField.backgroundColor!)
        cellView?.addSubview(textField)
        textField.layout(into: cellView!, insets: NSEdgeInsets(top: 0, left: 3, bottom: 0, right: 10))
        textColumn.width = stringWidth(for: diagnostic)! + 13
        break
      }
    }
    return cellView
  }
}

private class ExpandedTableDiagnosticViewDelegate : TableDiagnosticViewDelegate {
  
  required init(diagnostics: [Diagnostic], iconColumn: NSTableColumn, textColumn: NSTableColumn) {
    super.init(diagnostics: diagnostics, iconColumn: iconColumn, textColumn: textColumn)
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return diagnostics.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        guard let kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk = tableColumn else {}
    var cellView: NSView?
    let diagnostic = diagnostics[row]
    if tableColumn === iconColumn {
      let imgView = NSImageView()
      imgView.image = icon(for: diagnostic)?.imageWithTint(.black)
      imgView.imageScaling = .scaleProportionallyUpOrDown
      let parentView = NSView()
      parentView.setBackgroundColor(iconColumnColor(for: diagnostic))
      parentView.addSubview(imgView)
      imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
      iconColumn.width = CGFloat(20)
      cellView = parentView
    } else {
      cellView = NSView()
      let textField = NSTextField(labelWithString: diagnostic.message)
      if let font = NSFont.init(name: "SFMono-Medium", size: 12) {
        textField.font = font
      }
      textField.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
      textField.sizeToFit()
      textField.drawsBackground = true
      textField.backgroundColor = textColumnColor(for: diagnostic)
      cellView?.setBackgroundColor(textField.backgroundColor!)
      cellView?.addSubview(textField)
      textField.layout(into: cellView!, insets: NSEdgeInsets(top: 0, left: 3, bottom: 0, right: 10))
      textColumn.width = stringWidth(for: diagnostic)! + 13
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
