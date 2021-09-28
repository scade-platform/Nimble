//
//  CodeEditorTextView+TextFormat.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 01.10.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Foundation


// MARK: - Formatting

extension CodeEditorTextView {
  
  var indentChar: Character { CodeEditorSettings.shared.insertSpaces ? " " : "\t" }
  
  var indentString: String {
    return String(repeating: indentChar,
                  count: CodeEditorSettings.shared.insertSpaces ? CodeEditorSettings.shared.tabSize : 1)
  }
  
  var lineComment: String? {
    return editorView?.document?.language?.configuration?.comments?.lineComment
  }
  
  var blockComment: String? {
    return nil
  }
  
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
  
  var selectedString: String {
    guard selectedIndex < string.endIndex else { return "" }
    return String(string[selectedIndex..<string.index(after: selectedIndex)])
  }
  
  var currentLine: String {
    return String(string[string.lineRange(at: selectedIndex)])
  }
  
  var currentIndent: String {
    let currentLine = self.currentLine
    
    guard let regexp = try? NSRegularExpression(pattern: "^[\\t ]+"),
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
  
  func isPairOpened(_ pair: (String, String), in str: String, at index: String.Index) -> Bool {
    guard let prev = str.index(index, offsetBy: -pair.0.count, limitedBy: str.startIndex) else { return false }
    return String(str.utf16[prev..<index]) == pair.0
  }
  
  func isPairClosed(_ pair: (String, String), in str: String, at index: String.Index) -> Bool {
    guard let next = str.index(index, offsetBy: pair.1.count, limitedBy: str.endIndex) else { return false }
    return String(str.utf16[index..<next]) == pair.1
  }
  
  
  // MARK: - Overrides
  
  override func insertText(_ string: Any, replacementRange: NSRange) {
    guard var input = string as? String else { return }
    
    if CodeEditorSettings.shared.insertSpaces {
      input = input.replacingOccurrences(of: "\t", with: indentString)
    }
    
    var pos = selectedIndex
    
    if replacementRange.location != NSNotFound {
      pos = self.string.utf16.index(self.string.startIndex,
                                    offsetBy: replacementRange.lowerBound,
                                    limitedBy: self.string.endIndex) ?? self.string.endIndex
    }
    
    
    if let pair = autoClosingPairs.first(where: { input == $0.0 }) {
      if pair.0 == pair.1, isPairClosed(pair, in: self.string, at: pos) {
        super.moveForward(self)
        
      } else if pair.0 == pair.1, isPairOpened(pair, in: self.string, at: pos) {
        super.insertText(input, replacementRange: replacementRange)
        
      } else {
        
        super.insertText(input, replacementRange: replacementRange)
        
        if replacementRange.location != NSNotFound {
          super.insertText(pair.1, replacementRange: NSRange(location: replacementRange.lowerBound + 1, length: 0))
        } else {
          super.insertText(pair.1, replacementRange: replacementRange)
        }
        
        super.moveBackward(self)
      }
      
    } else if let pair = autoClosingPairs.first(where: { input == $0.1 })  {
      
      // If pair is not closed, close it. Otherwise just move forward
      if !isPairClosed(pair, in: self.string, at: pos) {
        super.insertText(input, replacementRange: replacementRange)
        
      } else {
        super.moveForward(self)
      }
      
    } else {
      super.insertText(input, replacementRange: replacementRange)
    }
  }
  
  override func insertNewline(_ sender: Any?) {
    let currentIndent = self.currentIndent
    let autoIndent = self.needAutoIndent(at: selectedIndex)
    
    super.insertNewline(sender)
    super.insertText(currentIndent, replacementRange: selectedRange())
    
    if autoIndent {
      super.insertText(indentString, replacementRange: selectedRange())
      
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
  
  
  // MARK: - Line Comments
  
  func linesComment() {
    guard let lineComment = self.lineComment else { return }
    self.indent(selectedRange(), using: lineComment)
  }
  
  /// Returns `true` if succeds.
  /// Note: in contrast to '`linesComment`' it can fail when not every line starts from the `lineComment` string
  func linesUncomment() -> Bool  {
    guard let lineComment = self.lineComment else { return false }
    return self.unindent(selectedRange(), using: lineComment)
  }
  
  
  func toggleLinesComment() {
    guard !linesUncomment() else { return }
    linesComment()
  }
  
  
  // MARK: - Block Comments
  
  func linesBlockComment() {
    
  }
  
  
  func linesBlockUncomment() -> Bool {
    return false
  }
  
  
  func toggleBlockComment() {
    guard !linesBlockUncomment() else { return }
    linesBlockComment()
  }
  
  
  // MARK: - Indents
  
  func linesIndent() {
    self.indent(selectedRange(), using: indentString)
  }
  
  func linesUnindent() {
    self.unindent(selectedRange(), using: indentChar, indentLength: CodeEditorSettings.shared.tabSize)
  }
  
  
  private func indent(_ range: NSRange, using indentString: String, updateSelection: Bool = true) {
    guard let string = textStorage?.string else { return }
    
    var offset = 0
    
    string.lines(from: string.utf16.range(for: range)).forEach {
      let range = NSRange(location: string.utf16.offset(at: $0.lowerBound) + offset, length: 0)
      super.insertText(indentString, replacementRange: range)
      offset += indentString.count
    }
    
    if updateSelection {
      var selection = range.shifted(offset: indentString.count)
      selection.length += offset - indentString.count
      
      setSelectedRange(selection)
    }
  }
  
  private func unindent(_ range: NSRange, using indentString: String, updateSelection: Bool = true) -> Bool {
    guard let string = textStorage?.string else { return false }
    
    let lines = string.lines(from: string.utf16.range(for: range))
    guard lines.allSatisfy({ string[$0].starts(with: indentString)}) else { return false }
    
    var offset = 0
    
    lines.forEach {
      let range = NSRange(location: string.utf16.offset(at: $0.lowerBound) - offset, length: indentString.count)
      super.insertText("", replacementRange: range)
      offset += indentString.count
    }
    
    if updateSelection {
      var selection = range.shifted(offset: -indentString.count)
      selection.length -= offset - indentString.count
      
      setSelectedRange(selection)
    }
    
    return true
  }
  
  
  private func unindent(_ range: NSRange, using indentChar: Character, indentLength: Int) {
    guard let string = textStorage?.string else { return }
    
    var offset = 0
    
    string.lines(from: string.utf16.range(for: range)).forEach {
      var length = 0
      while length < indentLength {
        if string[string.index($0.lowerBound, offsetBy: length)] == indentChar {
          length += 1
        } else {
          break
        }
      }
      
      let range = NSRange(location: string.utf16.offset(at: $0.lowerBound) - offset, length: length)
      super.insertText("", replacementRange: range)
      offset += length
    }
  }
  
  
  // MARK: - Lines shifting
  
  func shiftLinesUp() {
    guard let string = textStorage?.string else { return }
    
    var selection = selectedRange()
    
    let selectedRange = string.utf16.range(for: selection)
    var shiftRange = string.linesRange(from: selectedRange)
    
    let selectionOffset = string.distance(from: shiftRange.lowerBound, to: selectedRange.lowerBound)
    
    if shiftRange.lowerBound != string.startIndex {
      var shiftText = string[shiftRange]
      
      let prevLineEnd = string.index(before: shiftRange.lowerBound)
      let insertPos = string.lineRange(at: prevLineEnd).lowerBound
      
      selection.location = string.offset(at: insertPos) + selectionOffset
      
      /// If it's the last line of the file then "move" `newLine` symbol to the end of the shift range
      if shiftRange.upperBound == string.endIndex {
        shiftText += "\n"
        shiftRange = prevLineEnd..<shiftRange.upperBound
      }
      
      super.insertText("", replacementRange: string.utf16.nsRange(for: shiftRange))
      super.insertText(shiftText, replacementRange: string.utf16.nsRange(for: insertPos..<insertPos))
      
      setSelectedRange(selection)
    }
  }
  
  
  func shiftLinesDown() {
    guard let string = textStorage?.string else { return }
    
    var selection = selectedRange()
    
    let selectedRange = string.utf16.range(for: selection)
    let shiftRange = string.linesRange(from: selectedRange)
    
    let selectionOffset = string.distance(from: shiftRange.lowerBound,
                                          to: selectedRange.lowerBound)
    
    if shiftRange.upperBound != string.endIndex {
      var shiftText = string[shiftRange]
      let insertPos = string.lineRange(at: shiftRange.upperBound).upperBound
      
      selection.location = string.offset(at: string.index(insertPos, offsetBy: -shiftText.count)) + selectionOffset
      
      /// If it's shifted to the end of the file, "move" `newLine` symbol to the begin
      if insertPos == string.endIndex {
        shiftText.removeLast()
        shiftText.insert("\n", at: shiftText.startIndex)
        selection.location += 1
      }
      
      super.insertText(shiftText, replacementRange: string.utf16.nsRange(for: insertPos..<insertPos))
      super.insertText("", replacementRange: string.utf16.nsRange(for: shiftRange))
      
      setSelectedRange(selection)
    }
  }
  
}

fileprivate extension NSRange {
  func shifted(offset: Int) -> NSRange {
    return NSRange(location: self.location + offset, length: self.length)
  }
}
