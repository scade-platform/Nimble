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
    syntaxMenuItem.submenu = CodeEditorSyntaxMenu.nsMenu
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


// MARK: - Utils

extension NSMenu {
  var selectedItems: [NSMenuItem] {
    self.items.filter{$0.state == .on}
  }
}


