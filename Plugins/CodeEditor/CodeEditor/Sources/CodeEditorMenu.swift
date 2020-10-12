//
//  CodeEditorViewMenu.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 05.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
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
    return true
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

    let shiftLineUpItem = NSMenuItem(title: "Shift Line Up", action: #selector(shiftLineUp(_:)), keyEquivalent: "")
    shiftLineUpItem.target = shared

    let shiftLineDownItem = NSMenuItem(title: "Shift Line Down", action: #selector(shiftLineDown(_:)), keyEquivalent: "")
    shiftLineDownItem.target = shared

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

    let unindentItem = NSMenuItem(title: "Toggle Block Comment", action: #selector(toggleBlockComment(_:)), keyEquivalent: "")
    unindentItem.target = shared

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
    guard let codeEditorTextView = codeEditor?.textView else { return }

    if !codeEditorTextView.linesUncomment() {
      codeEditorTextView.linesComment()
    }
  }

  @objc func toggleBlockComment(_ item: NSMenuItem) {

  }
}


// MARK: - Utils

extension NSMenu {
  var selectedItems: [NSMenuItem] {
    self.items.filter{$0.state == .on}
  }
}


