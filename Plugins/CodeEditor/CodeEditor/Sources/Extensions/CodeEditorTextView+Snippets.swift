//
//  CodeEditorTextView+Snippets.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 28.05.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor

extension NSAttributedString.Key {
  static let snippet = NSAttributedString.Key("Snippet")
}

// MARK: - CodeEditorTextView + Snippets

extension CodeEditorTextView {
  typealias Snippet = (range: NSRange, view: NSView)

  var range: NSRange { NSRange(location: 0, length: textStorage?.length ?? 0) }

  var snippets: [Snippet] {
    get {
      return textStorage?.snippets(in: range) ?? []
    }
    set {
      textStorage?.enumerateSnippets(in: range) {
        textStorage?.removeAttribute(.snippet, range: $0.range)
      }

      snippetViews.forEach { $0.removeFromSuperview() }
      textContainer?.exclusionPaths = []
      addSnippets(newValue)
    }
  }

  private func addSnippets(_ snippets: [Snippet]) {
    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer,
          let textStorage = self.textStorage else { return }

    // Before accessing glyphes bounds, ensure the text is layouted
    layoutManager.ensureLayout(for: textContainer)

    var exclusionPaths = [NSBezierPath]()

    for s in snippets {
      let glyphRange = layoutManager.glyphRange(forCharacterRange: s.range, actualCharacterRange: nil)
      let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

      s.view.frame.origin = glyphRect.origin
      self.addSubview(s.view)
      self.snippetViews.append(s.view)

      var pathRect = s.view.frame
      pathRect.size.width += 2.0
      s.view.frame.origin.x += 1.0

      let path = NSBezierPath(rect: pathRect)
      exclusionPaths.append(path)
    }

    // Add exclusion paths all together, otherwise every append causes a re-layout
    textContainer.exclusionPaths = exclusionPaths

    // Add snippet attributes after the exclusion paths are added
    snippets.forEach {
      textStorage.addAttributes([.snippet: $0.view], range: $0.range)
    }
  }

  func nextSnippet(at index: Int = 0) -> Snippet? {
    guard let range = visibleRange ?? textStorage?.range,
          range.contains(index) else { return nil }

    return textStorage?.snippets(in: index..<range.upperBound).first
  }

  func prevSnippet(at index: Int = 0) -> Snippet? {
    guard let range = visibleRange ?? textStorage?.range,
          range.contains(index) else { return nil }

    return textStorage?.snippets(in: range.lowerBound..<index).last
  }

  @discardableResult
  func selectSnippet(in range: NSRange) -> Bool {
    if let snippet = textStorage?.snippets(in: range).first {
      window?.makeFirstResponder(snippet.view)
      return true
    }
    return false
  }

  @discardableResult
  func selectClosestSnippet() -> Bool {
    guard let snippet = nextSnippet(at: selectedRange().upperBound) else {
      return false
    }

    let substr = string[selectedRange().lowerBound..<snippet.range.lowerBound]

    if substr.numberOfLines < 4 {
      window?.makeFirstResponder(snippet.view)
      return true
    }

    return false
  }
}

// MARK: - NSTextStorage + Snippets

extension NSTextStorage {
  typealias Snippet = CodeEditorTextView.Snippet

  func enumerateSnippets(in range: NSRange, using: (Snippet) -> Void) {
    enumerateAttribute(.snippet, in: range, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
      guard let view = value as? NSView else { return }
      using((range: range, view: view))
    }
  }

  func snippet(at position: Int) -> Snippet? {
    var range: NSRange = NSRange(location: position, length: 0)
    if let snippetView = attribute(.snippet, at: position, effectiveRange: &range) as? NSView {
      return (range: range, view: snippetView)
    }

    return nil
  }

  func snippets(in range: NSRange? = nil) -> [Snippet] {
    let range = range ?? self.range
    var snippets = [Snippet]()
    enumerateSnippets(in: range) {
      snippets.append($0)
    }
    return snippets
  }

  func snippets(in range: Range<Int>) -> [Snippet] {
    return snippets(in: NSRange(range))
  }
}


// MARK: - SnippetPlaceholderView

class SnippetPlaceholderView: NSTextView {

  var range: NSRange = NSRange()

  var text: String {
    get {
      self.textStorage?.string ?? ""
    }
    set {
      self.replaceCharacters(in: textRange, with: newValue)
    }
  }

  private var selected: Bool = false {
    didSet {
      invalidate()
    }
  }

  private var textRange: NSRange { self.textStorage?.range ?? NSRange() }

  private var editorView: CodeEditorTextView? { superview as? CodeEditorTextView }

  override var shouldDrawInsertionPoint: Bool  {false}

  init() {
    super.init(frame: .zero)

    self.wantsLayer = true
    self.layer?.masksToBounds = true
    self.layer?.cornerRadius = 4.0

    self.isEditable = false
    self.textContainer?.lineFragmentPadding = 0
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
  }

  override func viewDidMoveToSuperview() {
    if let font = self.editorView?.font {
      self.font = font
    }

    invalidate()
  }

  func invalidate() {
    let attrs: [NSAttributedString.Key : Any] = [
      .font: self.font!,
      .foregroundColor: NSColor.white,
      .backgroundColor: self.selected ? NSColor.systemBlue : NSColor.lightGray
    ]

    self.textStorage?.setAttributes(attrs, range: textRange)

    guard let layoutManager = self.layoutManager,
          let textContainer = self.textContainer else { return }

    layoutManager.ensureLayout(for: textContainer)
    self.frame.size = layoutManager.usedRect(for: textContainer).size
  }

  func substituteText() {
    editorView?.setCursorPosition(range.upperBound)
    window?.makeFirstResponder(editorView)
    editorView?.insertText(self.string, replacementRange: range)
  }

  override func becomeFirstResponder() -> Bool {
    selected = true
    return super.becomeFirstResponder()
  }

  override func resignFirstResponder() -> Bool {
    selected = false
    return super.resignFirstResponder()
  }

  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case Keycode.leftArrow:
      editorView?.setCursorPosition(range.lowerBound - 1)
      editorView?.moveForward(nil)
      window?.makeFirstResponder(editorView)

    case Keycode.rightArrow:
      editorView?.setCursorPosition(range.upperBound + 1)
      editorView?.moveBackward(nil)
      window?.makeFirstResponder(editorView)

    case Keycode.upArrow:
      editorView?.setCursorPosition(range.lowerBound + 1)
      editorView?.moveUp(nil)
      window?.makeFirstResponder(editorView)

    case Keycode.downArrow:
      editorView?.setCursorPosition(range.upperBound - 1)
      editorView?.moveDown(nil)
      window?.makeFirstResponder(editorView)

    case Keycode.returnKey:
      substituteText()

    case Keycode.delete:
      textStorage?.replaceCharacters(in: textStorage?.range ?? NSRange(), with: "")
      substituteText()

    case Keycode.tab:
      if let snippet = editorView?.nextSnippet(at: range.upperBound) ??
                        editorView?.prevSnippet(at: range.lowerBound) {

        self.window?.makeFirstResponder(snippet.view)
      }

    case _ where Keycode.chars.contains(event.keyCode):
      if let chars = event.charactersIgnoringModifiers {
        textStorage?.replaceCharacters(in: textStorage?.range ?? NSRange(), with: chars)
        substituteText()
      }

    default:
      break
    }
  }
}
