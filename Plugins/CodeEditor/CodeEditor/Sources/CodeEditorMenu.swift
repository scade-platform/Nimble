//
//  CodeEditorViewMenu.swift
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


fileprivate var codeEditor: CodeEditorView? {
  codeEidtorDocument?.editor as? CodeEditorView
}

fileprivate var codeEidtorDocument: CodeEditorDocument? {
  return NSApp.currentWorkbench?.currentDocument as? CodeEditorDocument
}


// MARK: - Syntax menu

class CodeEditorSyntaxMenu: NSObject {
  static let shared = CodeEditorSyntaxMenu()
  
  static let nsMenu: NSMenu = {
    let menu = NSMenu(title: "Syntax")
    
    let autoLang = NSMenuItem(title: "Plain Text", action: #selector(selectSyntax(_:)), keyEquivalent: "")
    autoLang.target = shared
    
    var items = [autoLang]
    
    for lang in LanguageManager.shared.languages {
      let item = NSMenuItem(title: lang.aliases.first ?? lang.id, action: #selector(selectSyntax(_:)), keyEquivalent: "")
      item.target = shared
      item.representedObject = lang
      items.append(item)
    }
    
    items.sort { return $0.title < $1.title }
    menu.items = items
    
    return menu
  }()
  
  static func fillMenu(nsMenu: NSMenu) {
    let syntaxMenuItem = NSMenuItem(title: "Syntax", action: nil, keyEquivalent: "")
    syntaxMenuItem.submenu = self.nsMenu
    nsMenu.addItem(syntaxMenuItem)
  }
  
  static func itemState(_ item: NSMenuItem) -> NSControl.StateValue {
    let lang = item.representedObject as AnyObject?
    let currentLang = codeEidtorDocument?.language
    return (lang === currentLang) ? .on : .off
  }
  
  
  @objc func selectSyntax(_ item: NSMenuItem) {
    codeEidtorDocument?.language = item.representedObject as? Language
  }
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else {return true}
    item.state = CodeEditorSyntaxMenu.itemState(item)
    return true
  }
}

// MARK: - Show Completion

class CodeEditorShowCompletionMenuItem: NSObject {
  static let shared = CodeEditorShowCompletionMenuItem()
  
  static func fillMenu(nsMenu: NSMenu) {
    let item = NSMenuItem(title: "Show Completion", action: #selector(showCompletion(_:)), keyEquivalent: " ")
    item.target = shared
    item.keyEquivalentModifierMask = .control
    nsMenu.addItem(item)
  }
  
  @objc func showCompletion(_ item: NSMenuItem) {
    codeEditor?.showCompletion()
  }
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    return codeEditor?.supports(.completion) ?? false
  }
}


// MARK: - Format Document

class CodeEditorFormatDocumentMenuItem: NSObject {
  static let shared = CodeEditorFormatDocumentMenuItem()

  static func fillMenu(nsMenu: NSMenu) {
    let item = NSMenuItem(title: "Format Document", action: #selector(formatDocument(_:)), keyEquivalent: "i")
    item.target = shared
    item.keyEquivalentModifierMask = [.command, .control]
    nsMenu.addItem(item)
  }

  @objc func formatDocument(_ item: NSMenuItem) {
    codeEditor?.formatDocument()
  }

  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    return codeEditor?.supports(.format) ?? false
  }
}


// MARK: - Line

class CodeEditorLineMenuItem: NSObject {
  static let shared = CodeEditorLineMenuItem()

  static let nsMenu: NSMenu = {
    let indentItem = NSMenuItem(title: "Indent", action: #selector(indent(_:)), keyEquivalent: "]")
    indentItem.target = shared

    let unindentItem = NSMenuItem(title: "Unindent", action: #selector(unindent(_:)), keyEquivalent: "[")
    unindentItem.target = shared

    let shiftLineUpItem = NSMenuItem(title: "Shift Line Up", action: #selector(shiftLineUp(_:)), keyEquivalent: "\u{001e}")
    shiftLineUpItem.target = shared
    shiftLineUpItem.keyEquivalentModifierMask = [.command, .control]

    let shiftLineDownItem = NSMenuItem(title: "Shift Line Down", action: #selector(shiftLineDown(_:)), keyEquivalent: "\u{001f}")
    shiftLineDownItem.target = shared
    shiftLineDownItem.keyEquivalentModifierMask = [.command, .control]

    let menu = NSMenu(title: "Line")
    menu.items = [indentItem, unindentItem, shiftLineUpItem, shiftLineDownItem]

    return menu
  }()

  static func fillMenu(nsMenu: NSMenu) {
    let lineMenuItem = NSMenuItem(title: "Line", action: nil, keyEquivalent: "")
    lineMenuItem.submenu = self.nsMenu
    nsMenu.addItem(lineMenuItem)
  }

  @objc func indent(_ item: NSMenuItem) {
    codeEditor?.textView.linesIndent()

  }

  @objc func unindent(_ item: NSMenuItem) {
    codeEditor?.textView.linesUnindent()
  }

  @objc func shiftLineUp(_ item: NSMenuItem) {
    codeEditor?.textView.shiftLinesUp()
  }

  @objc func shiftLineDown(_ item: NSMenuItem) {
    codeEditor?.textView.shiftLinesDown()
  }
}


// MARK: - Comment

class CodeEditorCommentMenuItem: NSObject {
  static let shared = CodeEditorCommentMenuItem()

  static let nsMenu: NSMenu = {
    let indentItem = NSMenuItem(title: "Toggle Comment", action: #selector(toggleComment(_:)), keyEquivalent: "/")
    indentItem.target = shared

    let unindentItem = NSMenuItem(title: "Toggle Block Comment", action: #selector(toggleBlockComment(_:)), keyEquivalent: "/")
    unindentItem.target = shared
    unindentItem.keyEquivalentModifierMask = [.command, .option]

    let menu = NSMenu(title: "Line")
    menu.items = [indentItem, unindentItem]

    return menu
  }()

  static func fillMenu(nsMenu: NSMenu) {
    let commentMenuItem = NSMenuItem(title: "Comment", action: nil, keyEquivalent: "")
    commentMenuItem.submenu = self.nsMenu
    nsMenu.addItem(commentMenuItem)
  }

  @objc func toggleComment(_ item: NSMenuItem) {
    codeEditor?.textView.toggleLinesComment()
  }

  @objc func toggleBlockComment(_ item: NSMenuItem) {
    codeEditor?.textView.toggleBlockComment()
  }

  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else { return false }

    switch item.title {
    case "Toggle Comment":
      return codeEditor?.textView.lineComment != nil
    case "Toggle Block Comment":
      return codeEditor?.textView.blockComment != nil
    default:
      return false
    }
  }
}


// MARK: - Utils

extension NSMenu {
  var selectedItems: [NSMenuItem] {
    self.items.filter{$0.state == .on}
  }
}


