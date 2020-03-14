//
//  CodeEditorDiagnosticView.swift
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
  private weak var textView: NSTextView?
  private let line: Int
  
  private(set) var diagnostics: [Diagnostic] = [] {
    didSet {
      guard !diagnostics.isEmpty else { return }
      let collapsedRow = DiagnosticRowView.loadFromNib()
      let collapsedView = DiagnosticTableView(delegate: SummaryDiagnosticsRowViewDelegate(font: font))
      collapsedView.add(row: collapsedRow)
      collapsedView.mouseDownCallBack = mouseDownHandler
      collapsedRow.diagnostics = diagnostics
      self.addArrangedSubview(collapsedView)
      if diagnostics.count > 1 {
        if !errors.isEmpty {
          addTable(for: errors, isHidden: true)
        }
        if !warnings.isEmpty {
          addTable(for: warnings, isHidden: true)
        }
      }
    }
  }
  
  private lazy var errors : [Diagnostic] = {
    return diagnostics.filter{$0.severity == .error}
  }()
  
  private lazy var warnings : [Diagnostic] = {
    return diagnostics.filter{$0.severity == .warning}
  }()
  
  lazy var font: NSFont = {
    guard let font = textView?.font else {
      return NSFont.systemFont(ofSize: NSFont.systemFontSize)
    }
    return font
  }()
  
  init(textView: NSTextView, diagnostics: [Diagnostic], line: Int) {
    self.textView = textView
    self.line = line
    
    super.init(frame: .zero)
    
    self.orientation = .vertical
    self.alignment = .trailing
    self.spacing = 8
        
    set(diagnostics: diagnostics)
    setupView()
    
    ThemeManager.shared.observers.add(observer: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func mouseDownHandler() {
    if self.subviews.count > 1 {
      //when expand hide other diagnostic view
      if let textView = textView {
        textView.subviews.filter{$0 is DiagnosticView}.filter{$0 !== self}.forEach{$0.isHidden = !$0.isHidden}
      }
      self.arrangedSubviews.forEach{$0.isHidden = !$0.isHidden}
    }
   }
  
  private func addTable(for diagnostics: [Diagnostic], isHidden: Bool = false){
    let tableView = DiagnosticTableView(delegate: SingleDiagnosticRowViewDelegate(font: font))
    for diagnostic in diagnostics {
      let row = DiagnosticRowView.loadFromNib()
      tableView.add(row: row)
      row.diagnostics = [diagnostic]
    }
    tableView.isHidden = isHidden
    tableView.mouseDownCallBack = mouseDownHandler
    self.addArrangedSubview(tableView)
  }
  
  private func set(diagnostics: [Diagnostic]) {
    self.diagnostics = diagnostics
  }
  
  private func setupView() {
    guard let textView = textView, let textStorage = textView.textStorage else {
      return
    }
    textView.addSubview(self)
    let defaultLineHeight = textView.layoutManager?.defaultLineHeight(for: textView.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize))
    let lineHeight = defaultLineHeight! * (textView.defaultParagraphStyle?.lineHeightMultiple ?? 1)
    let lineRange: Range<Int> = textStorage.string.lineRange(line: line - 1)
    let string = String(textStorage.string[lineRange])
    self.translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalToConstant: textView.bounds.width - textView.stringWidth(for: string)!).isActive = true
    self.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -10).isActive = true
    self.topAnchor.constraint(equalTo: textView.topAnchor, constant: lineHeight * CGFloat(line - 1)).isActive = true
  }
}

extension DiagnosticView: ThemeObserver {
  func colorThemeDidChanged(_ theme: Theme) {
    self.subviews.forEach{$0.removeFromSuperview()}
    let d = self.diagnostics
    self.diagnostics = d
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

class DiagnosticRowViewDelegateImpl: DiagnosticRowViewDelegate {
  let font: NSFont
  
  init(font: NSFont) {
    self.font = font
  }
  
  func show(diagnostics: [Diagnostic], in row: DiagnosticRowView) {
    fatalError("show(diagnostics:,in:) has not been implemented")
  }
}

class SingleDiagnosticRowViewDelegate: DiagnosticRowViewDelegateImpl {
  
  override func show(diagnostics: [Diagnostic], in row: DiagnosticRowView) {
    guard let diagnostic = diagnostics.first else { return }
    addIcon(for: diagnostic, in: row.iconsView)
    row.iconsView.superview?.setBackgroundColor(DiagnosticViewUtils.iconColumnColor(for: diagnostic))
    addText(for: diagnostic, in: row.textView)
    row.setBackgroundColor(DiagnosticViewUtils.textColumnColor(for: diagnostic))
  }
  
  private func addIcon(for diagnostic: Diagnostic, in iconsView: NSStackView) {
    let imgView = NSImageView()
    imgView.image = DiagnosticViewUtils.icon(for: diagnostic)?.imageWithTint(.black)
    imgView.imageScaling = .scaleAxesIndependently
    imgView.heightAnchor.constraint(equalToConstant: 11).isActive = true
    imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 1).isActive = true
    let parentView = NSView()
    parentView.addSubview(imgView)
    imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 3, bottom: 3, right: 0))
    iconsView.addArrangedSubview(parentView)
  }
  
  private func addText(for diagnostic: Diagnostic, in textView: NSTextField) {
    textView.stringValue = diagnostic.message
    textView.font = font
    textView.textColor = ThemeManager.shared.currentTheme?.general.foreground
    textView.drawsBackground = true
    textView.backgroundColor = DiagnosticViewUtils.textColumnColor(for: diagnostic)
    textView.sizeToFit()
  }
}

class SummaryDiagnosticsRowViewDelegate: DiagnosticRowViewDelegateImpl {
  override func show(diagnostics: [Diagnostic], in row : DiagnosticRowView) {
    
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
    iconsView.superview?.setBackgroundColor(currentIconColumnColor!)
    if diagnostics.count > 1 {
      let countView = NSTextField(labelWithString: "\(diagnostics.count)")
      countView.font = font
      countView.textColor = ThemeManager.shared.currentTheme?.general.foreground
      countView.sizeToFit()

      countView.alignment = .center
      countView.drawsBackground = true
      countView.backgroundColor = currentIconColumnColor
      iconsView.addArrangedSubview(countView)
      countView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 751), for: .horizontal)
    }
    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      let imgView = NSImageView()
      imgView.imageScaling = .scaleAxesIndependently
      imgView.image = DiagnosticViewUtils.icon(for: diagnostic)?.imageWithTint(.black)
      imgView.heightAnchor.constraint(equalToConstant: 11).isActive = true
      imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 1).isActive = true
      let parentView = NSView()
      parentView.setBackgroundColor(currentIconColumnColor!)
      parentView.addSubview(imgView)
      imgView.layout(into: parentView, insets: NSEdgeInsets(top: 3, left: 0, bottom: 3, right: 0))
      iconsView.addArrangedSubview(parentView)
    }
  }
  
  private func addText(for diagnostics: [Diagnostic], in textView: NSTextField) -> NSColor? {
    textView.lineBreakMode = .byTruncatingTail
    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      textView.stringValue = diagnostic.message
      textView.font = font
      textView.textColor = ThemeManager.shared.currentTheme?.general.foreground
      textView.drawsBackground = true
      textView.backgroundColor = DiagnosticViewUtils.textColumnColor(for: diagnostic)
      textView.sizeToFit()
      return textView.backgroundColor
    }
    return nil
  }
}

fileprivate class DiagnosticTableView: NSView {
  let stackView: NSStackView
  var mouseDownCallBack: (() -> Void)?
  var diagnosticDelegate: DiagnosticRowViewDelegate? = nil
  
  //Add rounded corners to the target view
  init(delegate: DiagnosticRowViewDelegate) {
    self.diagnosticDelegate = delegate
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
    self.stackView.layout(into: self)
  }
  
  func add(row view: DiagnosticRowView) {
    view.diagnosticDelegate = diagnosticDelegate
    self.stackView.addArrangedSubview(view)
    view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
  }
  
  override func mouseDown(with event: NSEvent) {
    mouseDownCallBack?()
  }
}

fileprivate class DiagnosticViewUtils {
  
  enum ThemeKind {
    case dark
    case light
  }

  static var themeKind : ThemeKind {
    guard let backgroundColor = ThemeManager.shared.currentTheme?.general.background else {
      return .dark
    }
    return backgroundColor.lightnessComponent > CGFloat(0.5) ? .light : .dark
  }
  
  fileprivate static func iconColumnColor(for diagnostic: Diagnostic) -> NSColor {
    switch diagnostic.severity {
    case .error:
      switch themeKind {
      case .light:
        return NSColor(colorCode: "#ffc1c0")!
      default:
        return NSColor(colorCode: "#853332")!
      }
    case .warning:
      switch themeKind {
      case .light:
        return NSColor(colorCode: "#ffebad")!
      default:
        return NSColor(colorCode: "#907723")!
      }
    default:
      return NSColor(colorCode: "#c9ccc8")!
    }
  }

  fileprivate static func textColumnColor(for diagnostic: Diagnostic) -> NSColor {
    switch diagnostic.severity {
    case .error:
      switch themeKind {
      case .light:
        return NSColor(colorCode: "#f5e3e3")!
      default:
        return NSColor(colorCode: "#382829")!
      }
    case .warning:
      switch themeKind {
      case .light:
        return NSColor(colorCode: "#f5efdd")!
      default:
        return NSColor(colorCode: "#382829")!
      }
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


fileprivate extension NSView {
  func layout(into: NSView, insets: NSEdgeInsets = NSEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)) {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(equalTo: into.topAnchor, constant: insets.top).isActive = true
    self.bottomAnchor.constraint(equalTo: into.bottomAnchor, constant: -insets.bottom).isActive = true
    self.leadingAnchor.constraint(equalTo: into.leadingAnchor, constant: insets.left).isActive = true
    self.trailingAnchor.constraint(equalTo: into.trailingAnchor, constant: -insets.right).isActive = true
  }
}

fileprivate extension NSTextView {
  func stringWidth(for string: String) -> CGFloat? {
    let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
    let atrStr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font : font])
    let tabsCount = string.filter{$0 == "\t"}.count
    return atrStr.size().width + (self.defaultParagraphStyle?.defaultTabInterval ?? 0.0) * CGFloat(tabsCount)
  }
}
