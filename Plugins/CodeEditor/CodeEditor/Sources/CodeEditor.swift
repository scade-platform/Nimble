//
//  CodeEditor.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import CoreText
import CoreGraphics

import NimbleCore
import CodeEditor


public final class CodeEditor: Module {
  public static var pluginClass: Plugin.Type = CodeEditorPlugin.self
}


open class CodeEditorPlugin: Plugin {
  required public init() {
    DocumentManager.shared.registerDocumentClass(SourceCodeDocument.self)
    
    // Load color themes
    ColorThemeManager.shared.load(from: resources/"Themes")
    
    // Setup menus
    setupMainMenu()
    
    // Load custom fonts
    loadCustomFonts()
  }
  
  
  private func setupMainMenu() {
    guard let mainMenu = NSApplication.shared.mainMenu else { return }
    guard let preferencesMenu = mainMenu.findItem(with: "Nimble/Preferences")?.submenu else { return }
    
    let colorThemeMenu = NSMenu(title: "Color Theme")
    let colorThemeMenuItem = NSMenuItem(title: "Color Theme", action: nil, keyEquivalent: "")
    colorThemeMenuItem.submenu = colorThemeMenu
    
    preferencesMenu.addItem(NSMenuItem.separator())
    preferencesMenu.addItem(colorThemeMenuItem)
    
    let defaultThemeItem = NSMenuItem(title: "Default", action: #selector(switchTheme(_:)), keyEquivalent: "")
    defaultThemeItem.target = self
    
    var themeItems = [defaultThemeItem]
    
    for theme in ColorThemeManager.shared.colorThemes {
      let themeItem = NSMenuItem(title: theme.name, action: #selector(switchTheme(_:)), keyEquivalent: "")
      themeItem.target = self
      themeItem.representedObject = theme
      themeItems.append(themeItem)
    }
    
    colorThemeMenu.items = themeItems
  }

  
  private func loadCustomFonts() {
    var fonts: [String] = []
    
    fonts.append(contentsOf: self.bundle.paths(forResourcesOfType: ".otf", inDirectory: "Fonts"))
    fonts.append(contentsOf: self.bundle.paths(forResourcesOfType: ".ttf", inDirectory: "Fonts"))
    
    for fontPath in fonts {
      guard let path = Path(fontPath) else { continue }
      
      guard let fontData = try? Data(contentsOf: path) else { continue }
      guard let fontDataProvider = CGDataProvider(data: fontData as CFData) else { continue }
      guard let font = CGFont(fontDataProvider) else { continue }
      
      var error: Unmanaged<CFError>? = nil
      _ = CTFontManagerRegisterGraphicsFont(font, &error)
    }
  }
  
  
  @objc func validateMenuItem(_ item: NSMenuItem?) -> Bool {
    guard let item = item else {return true}
    let itemTheme = item.representedObject as AnyObject?
    let currentTheme = ColorThemeManager.shared.selectedTheme
    item.state = (itemTheme === currentTheme) ? .on : .off
    return true
  }
  
  @objc func switchTheme(_ item: NSMenuItem?) {
    ColorThemeManager.shared.selectedTheme = item?.representedObject as? ColorTheme
  }
}
