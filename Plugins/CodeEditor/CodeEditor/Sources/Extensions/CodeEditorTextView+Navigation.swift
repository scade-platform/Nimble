//
//  CodeEditorTextView+Navigation.swift
//  CodeEditor.plugin
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
import CodeEditor

extension CodeEditorTextView {
  
  //TODO: User key bindings
  
  //cmd + left
  override func moveToBeginningOfLine(_ sender: Any?) {
    guard let firstCharIndex = currentLineSubstring.firstCharIndex, firstCharIndex < selectedIndex else {
      super.moveToBeginningOfLine(sender)
      return
    }
    setSelectedIndex(firstCharIndex)
  }
  
  //cmd + backspace
  override func deleteToBeginningOfLine(_ sender: Any?) {
    guard let firstCharIndex = currentLineSubstring.firstCharIndex, firstCharIndex < selectedIndex else {
      super.deleteToBeginningOfLine(sender)
      return
    }
    insertText("", replacementRange: firstCharIndex ..< selectedIndex)
  }
    
  //option + left
  override func moveWordLeft(_ sender: Any?) {
    let previouseWordIndex = findPreviousWordBeginingPosition(currentIndex: selectedIndex)
    setSelectedIndex(previouseWordIndex)
  }
  
  //option + right
  override func moveWordRight(_ sender: Any?) {
    let nextWordIndex = findNextWordEndingPosition(currentIndex: selectedIndex)
    setSelectedIndex(nextWordIndex)
  }
  
  //option + backspace
  override func deleteWordBackward(_ sender: Any?) {
    let previouseWordIndex = findPreviousWordBeginingPosition(currentIndex: selectedIndex)
    insertText("", replacementRange: previouseWordIndex ..< selectedIndex)
  }
}

fileprivate extension CodeEditorTextView {
  
  var currentLineSubstring: Substring {
    string[string.lineRange(at: selectedIndex)]
  }
  
  func setSelectedIndex(_ index: String.Index) {
    setSelectedRange(index ..< index)
  }
  
  func setSelectedRange(_ charRange: Range<String.Index>) {
    let nsRange = NSRange(charRange, in: string)
    setSelectedRange(nsRange)
  }
  
  func insertText(_ text: String, replacementRange: Range<String.Index>) {
    let nsRange = NSRange(replacementRange, in: string)
    insertText(text, replacementRange: nsRange)
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
