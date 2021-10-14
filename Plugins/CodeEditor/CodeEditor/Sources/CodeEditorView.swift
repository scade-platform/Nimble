//
//  CodeEditorController.swift
//  CodeEditor
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
    guard !completionView.handleKeyDown(with: event) else { return true }

    if completionView.isActive {
      if event.keyCode == Keycode.delete {
        textView.deleteBackward(nil)
        showCompletion(triggered: true)
        return true
      }
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
      guard let range = d.range(in: text) else { continue }

      // Do not show diagnostic for the snippet ranges
      guard textStorage.snippet(at: range.lowerBound) == nil else {
        continue
      }

      let color = d.severity == .error ? NSColor.red : NSColor.yellow

      let line = text.lineNumber(at: range.lowerBound) + 1
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

  // MARK: - Language Services

  public func showCompletion(triggered: Bool = false) {
    guard let doc = document else { return }

    let pos = textView.selectedIndex

    doc.languageService(for: .completion)?.complete(in: doc, at: pos) {[weak self] in
      guard let string = self?.textView.textStorage?.string,
            let cursor = self?.textView.selectedIndex, cursor >= $0 else { return }

      self?.completionView.itemsFilter = String(string[$0..<cursor])

      self?.completionView.completionItems = $1
      self?.completionView.reload()

      if $1.count > 0 {
        self?.completionView.open(at: string.utf16.offset(at: $0), triggered: triggered)
      } else if !triggered {
        // Let it open if it was opened explicitely (not triggered automatically), e.g. by the shortcut
        self?.completionView.open(at: string.utf16.offset(at: pos), triggered: triggered)
      } else {
        self?.completionView.close()
      }
    }
  }

  public func formatDocument() {
    guard let doc = document else { return }
    doc.languageService(for: .format)?.format(doc: doc)
  }

  public func supports(_ feature: LanguageServiceFeature) -> Bool {
    return document?.languageService(for: feature) != nil
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
    CodeEditorFormatDocumentMenuItem.fillMenu(nsMenu: menu)

    menu.addItem(NSMenuItem.separator())
    CodeEditorLineMenuItem.fillMenu(nsMenu: menu)
    CodeEditorCommentMenuItem.fillMenu(nsMenu: menu)

    return menu
  }()

  var statusBarItems: [WorkbenchStatusBarItem] {
    //We should update shared menu each time
    CodeEditorSyntaxMenu.nsMenu.update()
    //And then update menu button   
    statusBarView.syntaxMenuButton?.select(CodeEditorSyntaxMenu.nsMenu.selectedItems.first)
    let result = statusBarView.view as! EditorStatusBar
    let pos = textView.selectedPosition
    statusBarView.setCursorPosition(pos.line, pos.column)
    return [result]
  }

  func focus() -> Bool {
    return view.window?.makeFirstResponder(textView) ?? false
  }

  func publish(diagnostics: [Diagnostic]) {
    guard let textStorage = document?.textStorage else { return }
    
    let settingsDignostics = diagnostics.compactMap{$0 as? SettingDiagnostic}.map{EditorSettingDiagnostic(textStorage.string, diagnostic: $0)}
    
    if !settingsDignostics.isEmpty {
      self.diagnostics = settingsDignostics
      self.showDiagnostics()
    } else {
      self.diagnostics = diagnostics.compactMap { $0 as? SourceCodeDiagnostic }
      self.showDiagnostics()
    }
    
    
  }

  func languageDidChange(language: Language?) {
    statusBarView.updateSelectedSyntax()
  }
  
}


// MARK: - NSTextStorageDelegate

extension CodeEditorView: NSTextStorageDelegate {
  func textStorage(_ textStorage: NSTextStorage,
                   didProcessEditing editedMask: NSTextStorageEditActions,
                   range editedRange: NSRange,
                   changeInLength delta: Int) {

    guard editedMask.contains(.editedCharacters) else { return }

    document?.updateChangeCount(.changeDone)
    
    // Update highlighting
    guard let syntaxParser = document?.syntaxParser else { return }

    DispatchQueue.main.async { [weak self] in
      // highlighProgress refers to the whole text highlighting
      if let progress = self?.highlightProgress {
        progress.cancel()
        self?.highlightProgress = syntaxParser.highlightAll()
      } else {
        let _ = syntaxParser.highlightAround(editedRange: editedRange, changeInLength: delta)
      }
    }
  }
}

// MARK: - CodeEditorTextViewDelegate

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
      if let str = string[m.range(at: 1)] {
        snippetView.text = String(str)
      } else {
        snippetView.text = ""
      }

      snippets.append((snippetView.range, snippetView))
    }

    textView.snippets = snippets
  }

  func textDidChange(_ notification: Notification) {
    invalidateSnippets()
  }

  func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
    guard let doc = document,
          let replacementString = replacementString else { return true }

    removeDiagnosticsViews()

    doc.observers.notify(as: SourceCodeDocumentObserver.self) {
      guard let text = textView.textStorage?.string else { return }            
      let range = text.range(for: text.utf16.range(for: affectedCharRange))
      $0.textDidChange(document: doc, range: range, text: replacementString)
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


// MARK: - CodeEditorTextViewDelegate

extension CodeEditorView: CodeEditorTextViewDelegate {
  func fontDidChange() {
    self.showDiagnostics()
  }
}
