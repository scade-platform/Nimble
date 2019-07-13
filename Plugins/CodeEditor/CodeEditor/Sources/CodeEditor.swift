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
import CodeEditorCore

public final class CodeEditor: Module {
  public static var pluginClass: Plugin.Type = CodeEditorPlugin.self
}


open class CodeEditorPlugin: Plugin {
  required public init() {
    DocumentManager.shared.registerDocumentClass(SourceCodeDocument.self)
    
    if let path = self.resourcePath {
      ColorThemeManager.shared.load(from: path/"Themes")
    }
    
    // TODO: move to a configuration file
    if let path = self.resourcePath {
      let swiftLang = Language(id: "swift", extensions: [".swift"])
      let swiftGrammar = LanguageGrammar(language: "swift",
                                         scopeName: "source.swift",
                                         path: path/"Syntaxes"/"swift.tmLanguage.json")
      
      LanguageManager.shared.add(language: swiftLang)
      LanguageManager.shared.add(grammar: swiftGrammar)
    }
    
    loadCustomFonts()
  }
  
  public func activate(workbench: Workbench) {

  }
  
  public func deactivate() {
    
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
}
