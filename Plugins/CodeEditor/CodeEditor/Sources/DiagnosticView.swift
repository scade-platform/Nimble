//
//  DiagnosticView.swift
//  CodeEditor.plugin
//
//  Created by Danil Kristalev on 16/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import CodeEditor

//The target view
class DiagnosticView: NSStackView {
  var diagnostics: [Diagnostic] = [] {
    didSet {
      guard !diagnostics.isEmpty else { return }
      let collapsedRow = DiagnosticRowView.loadFromNib()
      collapsedRow.diagnosticDelegate = SeveralDiagnosticsRowViewDelegate()
      collapsedRow.diagnostics = diagnostics
      let collapsedView = DiagnosticTableView()
      collapsedView.add(row: collapsedRow)
      collapsedView.mouseDownCallBack = mouseDownHandler
      self.addArrangedSubview(collapsedView)
      if !errors.isEmpty {
        let errorsView = DiagnosticTableView()
        for error in errors {
          let row = DiagnosticRowView.loadFromNib()
          row.diagnosticDelegate = SingleDiagnosticRowViewDelegate()
          row.diagnostics = [error]
          errorsView.add(row: row)
        }
        errorsView.isHidden = true
        errorsView.mouseDownCallBack = mouseDownHandler
        self.addArrangedSubview(errorsView)
      }
      if !warnings.isEmpty {
        let warningsView = DiagnosticTableView()
        for warning in warnings {
          let row = DiagnosticRowView.loadFromNib()
          row.diagnosticDelegate = SingleDiagnosticRowViewDelegate()
          row.diagnostics = [warning]
          warningsView.add(row: row)
        }
        warningsView.isHidden = true
        warningsView.mouseDownCallBack = mouseDownHandler
        self.addArrangedSubview(warningsView)
      }
    }
  }
  
  private lazy var errors : [Diagnostic] = {
    return diagnostics.filter{$0.severity == .error}
  }()
  
  private lazy var warnings : [Diagnostic] = {
    return diagnostics.filter{$0.severity == .warning}
  }()
  
  init() {
    super.init(frame: .zero)
    self.orientation = .vertical
    self.spacing = 8
    self.alignment = .trailing
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func mouseDownHandler() {
     self.arrangedSubviews.forEach{$0.isHidden = !$0.isHidden}
   }
  
}

class DiagnosticRowView: NSView {
  var diagnosticDelegate: DiagnosticRowViewDelegate? = nil
  
  
  @IBOutlet weak var iconsView: NSStackView!
  @IBOutlet weak var textView: NSTextField!
  
  
  var diagnostics: [Diagnostic] = [] {
    didSet {
      guard !diagnostics.isEmpty else { return }
      diagnosticDelegate?.show(diagnostics: diagnostics, in: self)
    }
  }
  
}

protocol DiagnosticRowViewDelegate {
  func show(diagnostics: [Diagnostic], in row: DiagnosticRowView)
}

class SingleDiagnosticRowViewDelegate: DiagnosticRowViewDelegate {
  
  func show(diagnostics: [Diagnostic], in row: DiagnosticRowView) {
    guard let diagnostic = diagnostics.first else { return }
    addIcon(for: diagnostic, in: row.iconsView)
    addText(for: diagnostic, in: row.textView)
    row.setBackgroundColor(DiagnosticViewUtils.textColumnColor(for: diagnostic))
  }
  
  private func addIcon(for diagnostic: Diagnostic, in iconsView: NSStackView) {
    let imgView = NSImageView()
    imgView.image = DiagnosticViewUtils.icon(for: diagnostic)?.imageWithTint(.black)
    imgView.imageScaling = .scaleProportionallyUpOrDown
    imgView.heightAnchor.constraint(equalToConstant: 15).isActive = true
    imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 1).isActive = true
    let parentView = NSView()
    parentView.setBackgroundColor(DiagnosticViewUtils.iconColumnColor(for: diagnostic))
    parentView.addSubview(imgView)
    imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
    iconsView.addArrangedSubview(parentView)
  }
  
  private func addText(for diagnostic: Diagnostic, in textView: NSTextField) {
    textView.stringValue = diagnostic.message
    if let font = DiagnosticViewUtils.font {
      textView.font = font
    }
    textView.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
    textView.drawsBackground = true
    textView.alignment = .center
    textView.backgroundColor = DiagnosticViewUtils.textColumnColor(for: diagnostic)
  }
}

class SeveralDiagnosticsRowViewDelegate: DiagnosticRowViewDelegate {
  func show(diagnostics: [Diagnostic], in row : DiagnosticRowView) {
    
    guard !diagnostics.isEmpty else { return }
    
    addIcons(for: diagnostics, in: row.iconsView)
    if let color = addText(for: diagnostics, in: row.textView) {
      row.setBackgroundColor(color)
    }
  }
  
  private func addIcons(for diagnostics: [Diagnostic], in iconsView: NSStackView) {
    var currentIconColumnColor: NSColor? = nil
    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      currentIconColumnColor =  DiagnosticViewUtils.iconColumnColor(for: diagnostic)
      break
    }
    if diagnostics.count > 1 {
      let countView = NSTextField(labelWithString: "\(diagnostics.count)")
      if let font = DiagnosticViewUtils.font {
        countView.font = font
      }
      countView.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
      countView.sizeToFit()
      countView.alignment = .center
      countView.drawsBackground = true
      countView.backgroundColor = currentIconColumnColor
      iconsView.addArrangedSubview(countView)
    }
    iconsView.superview?.setBackgroundColor(currentIconColumnColor!)
    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      let imgView = NSImageView()
      imgView.imageScaling = .scaleProportionallyUpOrDown
      imgView.image = DiagnosticViewUtils.icon(for: diagnostic)?.imageWithTint(.black)
      imgView.heightAnchor.constraint(equalToConstant: 15).isActive = true
      imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 1).isActive = true
      let parentView = NSView()
      parentView.setBackgroundColor(currentIconColumnColor!)
      parentView.addSubview(imgView)
      imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 0, bottom: 3, right: 0))
      iconsView.addArrangedSubview(parentView)
    }
  }
  
  private func addText(for diagnostics: [Diagnostic], in textView: NSTextField) -> NSColor? {
    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      textView.stringValue = diagnostic.message
      if let font = DiagnosticViewUtils.font {
        textView.font = font
      }
      textView.textColor = ColorThemeManager.shared.currentTheme?.global.foreground
      textView.sizeToFit()
      textView.drawsBackground = true
      textView.backgroundColor = DiagnosticViewUtils.textColumnColor(for: diagnostic)
      return textView.backgroundColor
    }
    return nil
  }
}

class DiagnosticTableView: NSView {
  let stackView: NSStackView
  var mouseDownCallBack: (() -> Void)?
  
  //Add rounded corners to the target view
  init() {
    self.stackView = NSStackView()
    super.init(frame: .zero)
    let layer = CALayer()
    layer.cornerRadius = 6.0
    layer.masksToBounds = true
    self.layer = layer
    setupStackView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupStackView() {
    self.addSubview(stackView)
    self.stackView.orientation = .vertical
    self.stackView.spacing = 0
    self.stackView.alignment = .trailing
    self.stackView.layout(into: self)
  }
  
  func add(row view: DiagnosticRowView) {
    self.stackView.addArrangedSubview(view)
  }
  
  override func mouseDown(with event: NSEvent) {
    mouseDownCallBack?()
  }
}

class DiagnosticViewUtils {
  static var font: NSFont? = {
    if let f = NSFont.init(name: "SFMono-Medium", size: 12) {
      return f
    }
    return nil
  }()
  
  //TODO: colores should be moved to themes
  // these colors for dark theme
  fileprivate static func iconColumnColor(for diagnostic: Diagnostic) -> NSColor {
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
  fileprivate static func textColumnColor(for diagnostic: Diagnostic) -> NSColor {
    switch diagnostic.severity {
    case .error:
      return NSColor(colorCode: "#382829")!
    case .warning:
      return NSColor(colorCode: "#382829")!
    default:
      return NSColor(colorCode: "#e7eae6")!
    }
  }

  fileprivate static func icon(for diagnostic: Diagnostic) -> NSImage? {
    switch diagnostic.severity {
    case .warning:
      return Bundle(for: self).image(forResource: "warning")
    case .error:
      return Bundle(for: self).image(forResource: "error")
    default:
      return nil
    }
  }
}
