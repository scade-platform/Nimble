//
//  CodeEditorController.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import CodeEditor


class CodeEditorView: NSViewController {
  @IBOutlet weak var textView: CodeEditorTextView!
  
  weak var document: CodeEditorDocument? = nil {
    didSet {
      guard isViewLoaded else { return }
      loadContent()
    }
  }
  
  var diagnostics: [SourceCodeDiagnostic] = []
  var diagnosticViews: [DiagnosticView] = []
  var diagnosticsUpdateTimer: DispatchSourceTimer? = nil
  
  
  private weak var highlightProgress: Progress? = nil
  
  private lazy var statusBarView: StatusBarView = {
    let view = StatusBarView.loadFromNib()
    view.textView = self.textView
    return view
  }()
  
  private lazy var completionView: CodeEditorCompletionView = {
    let view = CodeEditorCompletionView.loadFromNib()
    view.textView = self.textView
    _ = view.view    
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    textView.delegate = self
    ThemeManager.shared.observers.add(observer: self)
    loadContent()
  }

  override func viewDidLayout() {
    super.viewDidLayout()
    textView.textContainer?.exclusionPaths = []
    diagnosticViews.forEach {
      $0.updateConstraints()      
    }
  }

  func handleKeyDown(with event: NSEvent) -> Bool {
    if completionView.isActive {
      return completionView.handleKeyDown(with: event)
    }
    
    if shouldTriggerCompletion(with: event) {
      if let newText = event.charactersIgnoringModifiers {
        textView.insertText(newText, replacementRange: textView.selectedRange())
      }
      
      showCompletion(triggered: true)
      return true
    }
        
    return false
  }

  func handleMouseDown(with event: NSEvent) -> Bool {
    if completionView.isActive {
      completionView.close()
    }
    return false
  }
    
  private func shouldTriggerCompletion(with event: NSEvent) -> Bool {
    guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).isSubset(of: .shift) else { return false }
    
    ///TODO: react to any trigger symbols
    return Keycode.chars.contains(event.keyCode) || event.keyCode == Keycode.period
  }
  
  private func loadContent() {
    guard let layoutManager = textView.layoutManager,
          let doc = document else { return }
    
    layoutManager.replaceTextStorage(doc.textStorage)
    doc.textStorage.delegate = self

    if let theme = ThemeManager.shared.currentTheme {
      self.textView.font = theme.general.font

      textView.apply(theme: theme)

      highlightSyntax()
      invalidateSnippets()
    }
  }
      
  private func showDiagnostics() {
    guard let textStorage = document?.textStorage else { return }
    
    let text = textStorage.string
    let wholeRange = text.nsRange
    
    // Clean previous diagnostics
    textStorage.layoutManagers.forEach {
      //$0.removeTemporaryAttribute(.toolTip, forCharacterRange: wholeRange)
      $0.removeTemporaryAttribute(.underlineColor, forCharacterRange: wholeRange)
      $0.removeTemporaryAttribute(.underlineStyle, forCharacterRange: wholeRange)
    }
    
    // Show new diagnostics
    let style = NSNumber(value: NSUnderlineStyle.thick.rawValue)
    var lastLine = -1
    var diagnosticsOnLine: [SourceCodeDiagnostic] = []

    removeDiagnosticsViews()

    for d in diagnostics {
      let range = d.range(in: text)

      // Do not show diagnostic for the snippet ranges
      guard textStorage.snippet(at: range.lowerBound) == nil else {
        continue
      }

      let color = d.severity == .error ? NSColor.red : NSColor.yellow

      let line = text.lineNumber(at: range.lowerBound)
      if line != lastLine {
        if !diagnosticsOnLine.isEmpty {
          addDiagnosticsView(diagnosticsOnLine: diagnosticsOnLine, lastLine: lastLine)
        }
        diagnosticsOnLine = [d]
        lastLine = line
      } else {
        diagnosticsOnLine.append(d)
      }
      
      let lb = text.utf16(at: range.lowerBound)
      let ub = text.utf16(at: range.upperBound) + 1
      let nsRange = range.isEmpty ? NSRange(lb..<ub) : NSRange(range)
      
      textStorage.layoutManagers.forEach {
        //$0.addTemporaryAttribute(.toolTip, value: d.message, forCharacterRange: nsRange)
        $0.addTemporaryAttribute(.underlineColor, value: color, forCharacterRange: nsRange)
        $0.addTemporaryAttribute(.underlineStyle, value: style, forCharacterRange: nsRange)
      }
    }
    if !diagnosticsOnLine.isEmpty {
      addDiagnosticsView(diagnosticsOnLine: diagnosticsOnLine, lastLine: lastLine)
    }
  }
  
  private func addDiagnosticsView(diagnosticsOnLine: [SourceCodeDiagnostic], lastLine: Int) {
    let diagnosticView = DiagnosticView(textView: textView, line: lastLine)
    diagnosticView.diagnostics = diagnosticsOnLine
    self.diagnosticViews.append(diagnosticView)
  }

  private func removeDiagnosticsViews() {
    diagnosticViews.forEach{ $0.removeFromSuperview() }
    diagnosticViews.removeAll()
    textView.textContainer?.exclusionPaths = []
  }
  
  private func scheduleDiagnosticsUpdate() {
    if let timer = diagnosticsUpdateTimer {
      timer.cancel()
    }
    
    let timer = DispatchSource.makeTimerSource(queue: .main)
    timer.schedule(deadline:  .now() + 2.0) // 2 seconds delay
    timer.setEventHandler{[weak self] in
      self?.showDiagnostics()
    }
    timer.resume()
    
    diagnosticsUpdateTimer = timer
  }
  
  public func highlightSyntax() {
    if let doc = document {
      guard let syntaxParser = doc.syntaxParser else {
        doc.textStorage.layoutManagers.forEach {
          $0.removeTemporaryAttribute(.foregroundColor, forCharacterRange: doc.textStorage.range)
        }
        return
      }
      highlightProgress = syntaxParser.highlightAll()
    }
  }
  
  public func showCompletion(triggered: Bool = false) {
    guard let doc = document else { return }
    
    let pos = textView.selectedIndex
        
    ///TODO: filter langServices or merge results
    for langService in doc.languageServices {
      langService.complete(in: doc, at: pos) {[weak self] in                
        guard let string = self?.textView.textStorage?.string,
              let cursor = self?.textView.selectedIndex, cursor >= $0 else { return }
                
        self?.completionView.itemsFilter = String(string[$0..<cursor])
        
        self?.completionView.completionItems = $1
        self?.completionView.reload()
        
        if $1.count > 0 {
          self?.completionView.open(at: string.utf16.offset(at: $0), triggered: triggered)
        } else {
          self?.completionView.open(at: string.utf16.offset(at: pos), triggered: triggered)
        }
      }
    }
  }
}


// MARK: - ColorThemeObserver

extension CodeEditorView: ThemeObserver {
  func themeDidChanged(_ theme: Theme) {
    textView.apply(theme: theme)
    highlightSyntax()
  }
}


// MARK: - WorkbenchEditor

extension CodeEditorView: WorkbenchEditor {
  static var editorMenu: NSMenu? = {
    let menu = NSMenu()

    CodeEditorSyntaxMenu.fillMenu(nsMenu: menu)
    menu.addItem(NSMenuItem.separator())
    CodeEditorShowCompletionMenuItem.fillMenu(nsMenu: menu)

    return menu
  }()

  var statusBarItems: [WorkbenchStatusBarItem] {
    //We should update shared menu each time
    CodeEditorSyntaxMenu.nsMenu.update()
    //And then update menu button   
    statusBarView.syntaxMenuButton?.select(CodeEditorSyntaxMenu.nsMenu.selectedItems.first)

    return [statusBarView.view as! EditorStatusBar]
  }

  func focus() -> Bool {
    return view.window?.makeFirstResponder(textView) ?? false
  }

  func publish(diagnostics: [Diagnostic]) {
    self.diagnostics = diagnostics.compactMap { $0 as? SourceCodeDiagnostic }
    scheduleDiagnosticsUpdate()
  }
}


// MARK: - NSTextStorageDelegate

extension CodeEditorView: NSTextStorageDelegate {

  func undoManager(for view: NSTextView) -> UndoManager? {
    return document?.undoManager
  }

  func textStorage(_ textStorage: NSTextStorage,
                   didProcessEditing editedMask: NSTextStorageEditActions,
                   range editedRange: NSRange,
                   changeInLength delta: Int) {

    guard editedMask.contains(.editedCharacters) else { return }

    document?.updateChangeCount(.changeDone)
    
    // Update highlighting
    guard let syntaxParser = document?.syntaxParser else { return }
    let range = textStorage.editedRange

    DispatchQueue.main.async { [weak self] in
      if let progress = self?.highlightProgress {
        progress.cancel()
        self?.highlightProgress = syntaxParser.highlightAll()
      } else {
        let _ = syntaxParser.highlight(around: range)
      }
    }
  }
}

// MARK: - NSTextViewDelegate

extension CodeEditorView: NSTextViewDelegate {
  private static let snippetRegex = try? NSRegularExpression(pattern: "\\$\\{[0-9]+:(.*?)\\}")

  private func invalidateSnippets(in range: NSRange? = nil) {
    guard let string = textView.textStorage?.string,
          let matches = CodeEditorView.snippetRegex?.matches(in: string,
                                                             options: [],
                                                             range: range ?? string.nsRange) else { return }
    var snippets: [(NSRange, NSView)] = []

    for m in matches where m.numberOfRanges == 2 {
      let snippetView = SnippetPlaceholderView()

      snippetView.range = m.range(at: 0)
      snippetView.text = string[m.range(at: 1)] ?? ""

      snippets.append((snippetView.range, snippetView))
    }

    textView.snippets = snippets
  }

  func textDidChange(_ notification: Notification) {
    invalidateSnippets()
  }

  func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
    guard let doc = document else { return true }

    removeDiagnosticsViews()

    doc.observers.notify(as: SourceCodeDocumentObserver.self) {
      guard let text = textView.textStorage?.string else { return }            
      let range = text.range(for: text.utf16.range(for: affectedCharRange))
      $0.textDidChange(document: doc, range: range, text: replacementString ?? "")
    }
    
    return true
  }

  func textViewDidChangeSelection(_ notification: Notification) {
    let pos = textView.selectedPosition
    statusBarView.setCursorPosition(pos.line, pos.column)
    
    if completionView.isActive {
      let pos = completionView.completionPosition
      let newSel = textView.selectedRange()
      
      // Don't go behind the position where the completion has started
      if pos > newSel.lowerBound {
        completionView.close()
        return
      }
      
      if let str = textView.textStorage?.string {
        let filter = str[str.utf16.index(at: pos)..<str.utf16.index(at: newSel.lowerBound)]
        completionView.itemsFilter = String(filter)
        completionView.reload()
      }
    }
  }
}

