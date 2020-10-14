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
  fileprivate weak var textView: NSTextView?

  private let line: Int

  private var expanded: Bool = false

  private var topConstraint: NSLayoutConstraint? = nil
  private var widthConstraint: NSLayoutConstraint? = nil
  private var trailingConstraint: NSLayoutConstraint? = nil

  var diagnostics: [SourceCodeDiagnostic] = [] {
    didSet {
      guard !diagnostics.isEmpty else { return }

      let collapsedView = DiagnosticTableView(diagnosticView: self)
      collapsedView.delegate = SummaryDiagnosticsRowViewDelegate()

      let collapsedRow = DiagnosticRowView.loadFromNib()
      collapsedView.add(row: collapsedRow)
      collapsedView.mouseDownCallBack = mouseDownHandler

      collapsedRow.content = .diagnostics(diagnostics)
      self.addArrangedSubview(collapsedView)

      if diagnostics.count > 1 || diagnostics.contains(where: {!$0.fixes.isEmpty}) {
        if !errors.isEmpty {
          createTable(for: errors, isHidden: true)
        }
        if !warnings.isEmpty {
          createTable(for: warnings, isHidden: true)
        }
      }
    }
  }
  
  private lazy var errors : [SourceCodeDiagnostic] = {
    return diagnostics.filter{$0.severity == .error}
  }()
  
  private lazy var warnings : [SourceCodeDiagnostic] = {
    return diagnostics.filter{$0.severity == .warning}
  }()
  
  lazy var font: NSFont = {
    guard let font = textView?.font else {
      return NSFont.systemFont(ofSize: NSFont.systemFontSize)
    }
    return font
  }()
  
  init(textView: NSTextView, line: Int) {
    self.textView = textView
    self.line = line

    super.init(frame: .zero)

    self.translatesAutoresizingMaskIntoConstraints = false
    self.orientation = .vertical
    self.alignment = .trailing
    self.spacing = 8

    textView.addSubview(self)
    ThemeManager.shared.observers.add(observer: self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func updateConstraints() {
    guard let textView = textView as? CodeEditorTextView,
          let textStorage = textView.textStorage,
          let textContainer = textView.textContainer else { return }

    var lineRange = NSRange(textStorage.string.lineRange(line: line - 1))

    // Adjust lineRange to remove NEWLINE symbol
    // Otherwise the line width would span to the text view's width
    if lineRange.length > 1 {
      lineRange = NSRange(location: lineRange.location, length: lineRange.length - 1)
    }

    let lineSize =  textView.boundingRect(for: lineRange)?.size ?? NSSize()
    let defaultLineHeight = textView.layoutManager!.lineHeight

    let leadingOffset = min(0.8 * textView.frame.size.width, lineSize.width)

    let placeholder = NSRect(x: leadingOffset + 10,
                             y: defaultLineHeight * CGFloat(line - 1),
                             width: textView.frame.size.width - leadingOffset - 10,
                             height: defaultLineHeight)


    if !textContainer.exclusionPaths.contains(where: {$0.bounds == placeholder}) {
      textContainer.exclusionPaths.append(NSBezierPath(rect: placeholder))
    }

    if !expanded {
      if topConstraint == nil {
        topConstraint = self.topAnchor.constraint(equalTo: textView.topAnchor)
        topConstraint?.isActive = true
      }

      if widthConstraint == nil {
        widthConstraint = self.widthAnchor.constraint(lessThanOrEqualToConstant: 0.0)
        widthConstraint?.isActive = true
      }

      if trailingConstraint == nil {
        trailingConstraint = self.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        trailingConstraint?.isActive = true
      }

      topConstraint?.constant = placeholder.origin.y
      widthConstraint?.constant = placeholder.width
      trailingConstraint?.constant = 0.0

    } else {
      topConstraint?.constant = placeholder.origin.y + lineSize.height
      trailingConstraint?.constant = -40.0

      var maxWidth: CGFloat = 0
      diagnostics.forEach {
        guard let width = textView.stringWidth(for: $0.message) else { return }
        maxWidth = max(maxWidth, width)

        $0.fixes.forEach { quickfix in
          guard let width = textView.stringWidth(for: quickfix.title) else { return }
          maxWidth = max(maxWidth, width)
        }
      }
      widthConstraint?.constant = maxWidth + 30
    }


    super.updateConstraints()
  }

  func mouseDownHandler() {
    if self.subviews.count > 1 {
      //when expand hide other diagnostic view
//      if let textView = textView {
//        textView.subviews.filter{$0 is DiagnosticView}.filter{$0 !== self}.forEach{$0.isHidden = !$0.isHidden}
//      }
      expanded = !expanded

      self.arrangedSubviews.forEach{$0.isHidden = !$0.isHidden}

      self.bringToFront()      
      self.updateConstraints()
    }
   }
  
  private func createTable(for diagnostics: [SourceCodeDiagnostic], isHidden: Bool = false){
    let tableView = DiagnosticTableView(diagnosticView: self)
    tableView.delegate = SingleDiagnosticRowViewDelegate()

    for diagnostic in diagnostics {
      let row = DiagnosticRowView.loadFromNib()
      tableView.add(row: row)
      row.content = .diagnostic(diagnostic)

      for quickfix in diagnostic.fixes {
        let row = DiagnosticRowView.loadFromNib()
        tableView.add(row: row)
        row.content = .quickfix(quickfix, diagnostic)
      }
    }

    tableView.isHidden = isHidden
    tableView.mouseDownCallBack = mouseDownHandler
    self.addArrangedSubview(tableView)
  }
}


// MARK: - DiagnosticView + ThemeObserver

extension DiagnosticView: ThemeObserver {
  func colorThemeDidChanged(_ theme: Theme) {
    self.subviews.forEach{$0.removeFromSuperview()}
    let d = self.diagnostics
    self.diagnostics = d
  }
}

// MARK: - DiagnosticTableView

fileprivate class DiagnosticTableView: NSView {
  fileprivate weak var diagnosticView: DiagnosticView? = nil
  var delegate: DiagnosticRowViewDelegate? = nil

  let stackView: NSStackView = NSStackView()
  var mouseDownCallBack: (() -> Void)?

  //Add rounded corners to the target view
  init(diagnosticView: DiagnosticView) {
    self.diagnosticView = diagnosticView

    super.init(frame: .zero)

    self.addSubview(stackView)

    self.stackView.orientation = .vertical
    self.stackView.spacing = 0
    self.stackView.layout(into: self)

    self.wantsLayer = true
    self.layer?.cornerRadius = 2.0
    self.layer?.masksToBounds = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func add(row: DiagnosticRowView) {
    row.tableView = self

    self.stackView.addArrangedSubview(row)

    row.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
    row.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
  }

  override func mouseDown(with event: NSEvent) {
    mouseDownCallBack?()
  }
}

// MARK: - DiagnosticRowView

class DiagnosticRowView: NSView {
  fileprivate weak var tableView: DiagnosticTableView? = nil

  @IBOutlet weak var stackView: NSStackView!
  @IBOutlet weak var iconsView: NSStackView!
  @IBOutlet weak var messageView: NSTextField!

  var font: NSFont? {
    guard let font = tableView?.diagnosticView?.textView?.font else { return nil }
    return NSFont.systemFont(ofSize: font.pointSize)
  }

  var content: DiagnosticRowViewContent = .empty {
    didSet {
      switch content {
      case .diagnostics(let diagnostics):
        tableView?.delegate?.show(diagnostics: diagnostics, in: self)
      case .diagnostic(let diagnostic):
        tableView?.delegate?.show(diagnostic: diagnostic, in: self)
      case .quickfix(let quickfix, let diagnostic):
        tableView?.delegate?.show(quickfix: quickfix, from: diagnostic, in: self)
      default:
        return
      }
    }
  }

  @objc func fix() {
    guard case .quickfix(let quickfix, _) = content,
          let textView = tableView?.diagnosticView?.textView else { return }

    let range = quickfix.textEdit.range(in: textView.string)
    textView.insertText(quickfix.textEdit.newText, replacementRange: NSRange(range))
  }
}

enum DiagnosticRowViewContent {
  case diagnostics([SourceCodeDiagnostic])
  case diagnostic(SourceCodeDiagnostic)
  case quickfix(SourceCodeQuickfix, SourceCodeDiagnostic)
  case empty
}

// MARK: - Abstract Row Delegate

protocol DiagnosticRowViewDelegate {
  func show(diagnostics: [SourceCodeDiagnostic], in row: DiagnosticRowView)
  func show(diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView)
  func show(quickfix: SourceCodeQuickfix, from: SourceCodeDiagnostic, in: DiagnosticRowView)
}

class DiagnosticRowViewDelegateImpl: DiagnosticRowViewDelegate {
  func show(diagnostics: [SourceCodeDiagnostic], in row: DiagnosticRowView) {
    fatalError("show(diagnostics:,in:) has not been implemented")
  }

  func show(diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView) {
    fatalError("show(diagnostics:,in:) has not been implemented")
  }

  func show(quickfix: SourceCodeQuickfix, from diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView) {
    fatalError("show(quickfix:,in:) has not been implemented")
  }
}

// MARK: - Single Row Delegate

class SingleDiagnosticRowViewDelegate: DiagnosticRowViewDelegateImpl {
  
  override func show(diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView) {
    addIcon(for: diagnostic, in: row)
    row.iconsView.superview?.setBackgroundColor(DiagnosticViewUtils.iconColumnColor(for: diagnostic))

    addText(diagnostic.message, for: diagnostic, in: row)
    row.setBackgroundColor(DiagnosticViewUtils.textColumnColor(for: diagnostic))
  }

  override func show(quickfix: SourceCodeQuickfix, from diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView) {
    // Add a an empty icon holder
    let iconHolder = NSView()
    iconHolder.widthAnchor.constraint(equalToConstant: 10).isActive = true  // icon width
    iconHolder.heightAnchor.constraint(equalToConstant: 20).isActive = true // icon height + top and bottom insets

    row.iconsView.addArrangedSubview(iconHolder)
    row.iconsView.superview?.setBackgroundColor(DiagnosticViewUtils.iconColumnColor(for: diagnostic))

    // Add quickfix title
    addText(quickfix.title, for: diagnostic, in: row)
    row.setBackgroundColor(DiagnosticViewUtils.textColumnColor(for: diagnostic))

    // Add quickfix action button
    let fixButton = NSButton()
    fixButton.title = "Fix"
    fixButton.font = row.font
    fixButton.contentTintColor = ThemeManager.shared.currentTheme?.general.foreground
    fixButton.bezelColor = ThemeManager.shared.currentTheme?.general.foreground
    fixButton.bezelStyle = .roundRect
    fixButton.target = row
    fixButton.action = #selector(DiagnosticRowView.fix)

    let buttonHolder = NSView()
    buttonHolder.addSubview(fixButton)

    fixButton.layout(into: buttonHolder, insets: NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 3))
    row.stackView.addArrangedSubview(buttonHolder)
  }

  private func addIcon(for diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView) {
    let imgView = NSImageView()

    imgView.image = DiagnosticViewUtils.icon(for: diagnostic)?.imageWithTint(.black)
    imgView.imageScaling = .scaleAxesIndependently
    imgView.heightAnchor.constraint(equalToConstant: row.font?.capHeight ?? 10).isActive = true
    imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 1).isActive = true

    let parentView = NSView()
    parentView.addSubview(imgView)
    imgView.layout(into: parentView, insets: NSEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    row.iconsView.addArrangedSubview(parentView)
  }
  
  private func addText(_ text: String, for diagnostic: SourceCodeDiagnostic, in row: DiagnosticRowView) {
    row.messageView.stringValue = text
    row.messageView.font = row.font
    row.messageView.textColor = ThemeManager.shared.currentTheme?.general.foreground
    row.messageView.drawsBackground = true
    row.messageView.backgroundColor = DiagnosticViewUtils.textColumnColor(for: diagnostic)
    row.messageView.sizeToFit()
  }
}


// MARK: - Summary Row Delegate

class SummaryDiagnosticsRowViewDelegate: DiagnosticRowViewDelegateImpl {
  override func show(diagnostics: [SourceCodeDiagnostic], in row : DiagnosticRowView) {
    guard !diagnostics.isEmpty else { return }
    
    addIcons(for: diagnostics, in: row)
    if let color = addText(for: diagnostics, in: row) {
      row.setBackgroundColor(color)
    }
  }
  
  private func addIcons(for diagnostics: [SourceCodeDiagnostic], in row : DiagnosticRowView) {
    var currentIconColumnColor: NSColor? = nil

    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }
      currentIconColumnColor =  DiagnosticViewUtils.iconColumnColor(for: diagnostic)
      break
    }

    row.iconsView.superview?.setBackgroundColor(currentIconColumnColor!)

    if diagnostics.count > 1 {
      let countView = NSTextField(labelWithString: "\(diagnostics.count)")
      countView.font = row.font
      countView.textColor = ThemeManager.shared.currentTheme?.general.foreground
      countView.sizeToFit()

      countView.alignment = .center
      countView.drawsBackground = true
      countView.backgroundColor = currentIconColumnColor
      row.iconsView.addArrangedSubview(countView)
      countView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 751), for: .horizontal)
    }

    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }

      let imgView = NSImageView()
      imgView.imageScaling = .scaleAxesIndependently
      imgView.image = DiagnosticViewUtils.icon(for: diagnostic)?.imageWithTint(.black)
      imgView.heightAnchor.constraint(equalToConstant: row.font?.capHeight ?? 10).isActive = true
      imgView.widthAnchor.constraint(equalTo: imgView.heightAnchor, multiplier: 1).isActive = true

      let parentView = NSView()
      parentView.setBackgroundColor(currentIconColumnColor!)
      parentView.addSubview(imgView)
      imgView.layout(into: parentView, insets: NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))

      row.iconsView.addArrangedSubview(parentView)
    }
  }
  
  private func addText(for diagnostics: [SourceCodeDiagnostic], in row : DiagnosticRowView) -> NSColor? {
    row.messageView.lineBreakMode = .byTruncatingTail

    for diagnosticType in DiagnosticSeverity.allCases {
      guard let diagnostic = diagnostics.first(where: {$0.severity == diagnosticType}) else { continue }

      row.messageView.stringValue = diagnostic.message
      row.messageView.font = row.font

      row.messageView.textColor = ThemeManager.shared.currentTheme?.general.foreground
      row.messageView.drawsBackground = true
      row.messageView.backgroundColor = DiagnosticViewUtils.textColumnColor(for: diagnostic)
      row.messageView.sizeToFit()

      return row.messageView.backgroundColor
    }
    return nil
  }
}

// MARK: - Utils

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
  
  fileprivate static func iconColumnColor(for diagnostic: SourceCodeDiagnostic) -> NSColor {
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

  fileprivate static func textColumnColor(for diagnostic: SourceCodeDiagnostic) -> NSColor {
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

  fileprivate static func icon(for diagnostic: SourceCodeDiagnostic) -> NSImage? {
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


