//
//  CodeEditorViewMenu.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 05.12.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import CodeEditor

class CodeEditorMenu: NSObject {
  static let shared = CodeEditorMenu()
  
  var codeEditor: CodeEditorView? = nil
  
  lazy var nsMenu: NSMenu = {
    let menu = NSMenu()
    
    CodeEditorSyntaxMenuItem.fillMenu(nsMenu: menu)
    menu.addItem(NSMenuItem.separator())
    CodeEditorShowCompletionMenuItem.fillMenu(nsMenu: menu)
    
    return menu
  }()
}

// MARK: - Syntax menu

class CodeEditorSyntaxMenuItem: NSObject {
  private static let shared = CodeEditorSyntaxMenuItem()
  
  static func fillMenu(nsMenu: NSMenu) {
    let syntaxMenu = NSMenu(title: "Syntax")
    
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
    
    syntaxMenu.items = items
    
    let syntaxMenuItem = NSMenuItem(title: "Syntax", action: nil, keyEquivalent: "")
    syntaxMenuItem.submenu = syntaxMenu
    
    nsMenu.addItem(syntaxMenuItem)
  }
    
  @objc func selectSyntax(_ item: NSMenuItem) {
    CodeEditorMenu.shared.codeEditor?.document?.language = item.representedObject as? Language
  }
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else {return true}
    let lang = item.representedObject as AnyObject?
    let currentLang = CodeEditorMenu.shared.codeEditor?.document?.language
    item.state = (lang === currentLang) ? .on : .off
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
    CodeEditorMenu.shared.codeEditor?.showCompletion()
  }
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    return true
  }
}
