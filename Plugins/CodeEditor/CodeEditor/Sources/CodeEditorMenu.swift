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
    menu.addItem(CodeEditorSyntaxMenuItem.shared.nsMenuItem)
    return menu
  }()
}

class CodeEditorSyntaxMenuItem: NSObject {
  static let shared = CodeEditorSyntaxMenuItem()
  
  lazy var nsMenuItem: NSMenuItem = {
    let syntaxMenu = NSMenu(title: "Syntax")
    
    let autoLang = NSMenuItem(title: "Plain Text", action: #selector(selectSyntax(_:)), keyEquivalent: "")
    autoLang.target = self
    
    var items = [autoLang]
    
    for lang in LanguageManager.shared.languages {
      let item = NSMenuItem(title: lang.aliases.first ?? lang.id, action: #selector(selectSyntax(_:)), keyEquivalent: "")
      item.target = self
      item.representedObject = lang
      items.append(item)
    }
    
    items.sort { return $0.title < $1.title }
    
    syntaxMenu.items = items
    
    let syntaxMenuItem = NSMenuItem(title: "Syntax", action: nil, keyEquivalent: "")
    syntaxMenuItem.submenu = syntaxMenu
            
    return syntaxMenuItem
  }()
  
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
