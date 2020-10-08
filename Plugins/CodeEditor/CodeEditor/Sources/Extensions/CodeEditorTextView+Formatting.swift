//
//  CodeEditorTextView+TextFormat.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 01.10.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation


extension CodeEditorTextView {
  // MARK: - Auto-closing + auto-indents

  var autoClosingPairs: [(String, String)] {
    return editorView?.document?.language?.configuration?.autoClosingPairs ?? []
  }

  var selectedIndex: String.Index {
    // Use UTF-16 view as NSTextView returns index in UTF-16
    let utf16 = string.utf16
    return utf16.index(utf16.startIndex, offsetBy: selectedRange().location)
  }

  var selectedPosition: (line: Int, column: Int) {
    let sel = selectedIndex
    if let str = textStorage?.string {
      let line = str.lineNumber(at: sel)
      let lineStart = str.lineRange(at: sel).lowerBound
      let column = str.utf16.distance(from: lineStart, to: sel)

      return (line, column)
    }

    return (0, 0)
  }

  var currentLine: String {
    return String(string[string.lineRange(at: selectedIndex)])
  }

  var currentIndent: String {
    let currentLine = self.currentLine
    guard let regexp = try? NSRegularExpression(pattern: "^(\\t|\\s)+"),
      let result = regexp.firstMatch(in: currentLine,
                                     range: NSRange(0..<currentLine.count)) else { return "" }

    return String(currentLine[result.range.lowerBound..<result.range.upperBound])
  }


  func setCursorPosition(_ pos: Int) {
    setSelectedRange(NSRange(location: pos, length: 0))
  }

  func surroundRange(_ index: String.Index) -> Range<String.Index> {
    let lineRange = string.lineRange(at: selectedIndex)
    let from = (index > lineRange.lowerBound) ? string.index(before: index) : lineRange.lowerBound
    let to = (index < lineRange.upperBound) ? string.index(after: index) : lineRange.upperBound
    return from..<to
  }

  func surroundString(_ index: String.Index) -> String {
    return String(string[surroundRange(index)])
  }

  func needAutoIndent(at index: String.Index) -> Bool {
    let str = self.surroundString(index)
    return autoClosingPairs.contains{$0.0 + $0.1 == str}
  }

  override func insertText(_ string: Any, replacementRange: NSRange) {
    super.insertText(string, replacementRange: replacementRange)
    guard let input = string as? String else { return }

    if let pair = autoClosingPairs.first(where: { input == $0.0 }) {
      super.insertText(pair.1, replacementRange: replacementRange)
      super.moveBackward(self)
    }
  }

  override func insertNewline(_ sender: Any?) {
    let currentIndent = self.currentIndent

    super.insertNewline(sender)
    super.insertText(currentIndent, replacementRange: selectedRange())

    if needAutoIndent(at: selectedIndex) {
      super.insertTab(sender)
      super.insertNewline(sender)
      super.insertText(currentIndent, replacementRange: selectedRange())

      super.moveToLeftEndOfLine(sender)
      super.moveBackward(sender)
    }
  }

  override func deleteBackward(_ sender: Any?) {
    if needAutoIndent(at: selectedIndex) {
      super.deleteForward(sender)
      super.deleteBackward(sender)

    } else if let snippet = textStorage?.snippetLeft(from: selectedRange().location) {
      self.insertText("", replacementRange: snippet.range)

    } else {
      super.deleteBackward(sender)
    }
  }

  override func moveLeft(_ sender: Any?) {
    if let snippet = textStorage?.snippetLeft(from: selectedRange().location) {
      window?.makeFirstResponder(snippet.view)
    } else {
      super.moveLeft(sender)
    }
  }

  override func moveRight(_ sender: Any?) {
    if let snippet = textStorage?.snippetRight(from: selectedRange().location) {
      window?.makeFirstResponder(snippet.view)
    } else {
      super.moveRight(sender)
    }
  }
}

