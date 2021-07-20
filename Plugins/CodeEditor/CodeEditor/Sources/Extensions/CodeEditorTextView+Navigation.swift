//
//  CodeEditorTextView+Navigation.swift
//  CodeEditor.plugin
//
//  Created by Danil Kristalev on 05.07.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor

extension CodeEditorTextView {
  
  //TODO: User key bindings
  
  //cmd + left
  override func moveToBeginningOfLine(_ sender: Any?) {
    guard let firstCharIndex = currentLineSubstring.firstCharIndex, firstCharIndex < selectedIndex else {
      super.moveToBeginningOfLine(sender)
      return
    }
    
    let nsRange = NSRange(firstCharIndex ..< firstCharIndex, in: string)
    setSelectedRange(nsRange)
  }
  
  //cmd + backspace
  override func deleteToBeginningOfLine(_ sender: Any?) {
    guard let firstCharIndex = currentLineSubstring.firstCharIndex, firstCharIndex < selectedIndex else {
      super.deleteToBeginningOfLine(sender)
      return
    }
    
    let nsRange = NSRange(firstCharIndex ..< selectedIndex, in: string)
    insertText("", replacementRange: nsRange)
  }
    
  //option + left
  override func moveWordLeft(_ sender: Any?) {
    let previouseWordIndex = findPreviousWordBeginingPosition(currentIndex: selectedIndex)
    let nsRange = NSRange(previouseWordIndex ..< previouseWordIndex, in: string)
    setSelectedRange(nsRange)
  }
  
  //option + right
  override func moveWordRight(_ sender: Any?) {
    let nextWordIndex = findNextWordEndingPosition(currentIndex: selectedIndex)
    let nsRange = NSRange(nextWordIndex ..< nextWordIndex, in: string)
    setSelectedRange(nsRange)
  }
}

fileprivate extension CodeEditorTextView {
  
  var currentLineSubstring: Substring {
    string[string.lineRange(at: selectedIndex)]
  }
  
  func findPreviousWordBeginingPosition(currentIndex: String.Index) -> String.Index {
    let substring = string[..<currentIndex]
    
    guard let index = substring.lastIndex(where: { $0.isWordSeparator }) else {
      return string.startIndex
    }
    
    let wordIndex = string.index(after: index)
    
    guard wordIndex != selectedIndex else {
      return findPreviousWordBeginingPosition(currentIndex: string.index(before: wordIndex))
    }
    
    let ch = string[wordIndex]
    guard !ch.isWordSeparator else {
      return findPreviousWordBeginingPosition(currentIndex: string.index(before: wordIndex))
    }
    
    return wordIndex
  }
  
  func findNextWordEndingPosition(currentIndex: String.Index) -> String.Index {
    guard currentIndex < string.endIndex else {
      return currentIndex
    }
    
    let startIndex = string.index(after: currentIndex)
    
    let substring = string[startIndex...]
    
    guard let wordIndex = substring.firstIndex(where: { $0.isWordSeparator }) else {
      return string.endIndex
    }
    
    let ch = string[string.index(before: wordIndex)]
    guard !ch.isWordSeparator else {
      return findNextWordEndingPosition(currentIndex: wordIndex)
    }
    
    return wordIndex
  }
}

fileprivate extension Substring {
  var firstCharIndex: String.Index? {
    firstIndex(where: { !$0.isWhitespace })
  }
}

fileprivate extension Character {
  var isWordSeparator: Bool {
    isWhitespace || isNewline || isPunctuation
  }
}
