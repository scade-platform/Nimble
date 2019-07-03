//
//  CodeEditor.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore
import CoreGraphics
import CoreText

public final class CodeEditor: Module {
  public static var pluginClass: Plugin.Type = CodeEditorPlugin.self
}


open class CodeEditorPlugin: Plugin {
  required public init() {
    DocumentManager.shared.registerDocumentClass(SourceCodeDocument.self)
    
//    ThemeManager.shared.loadDefaultDarkTheme()
//    SyntaxManager.shared.loadSwiftSyntax()
    
    loadCustomFonts()
  }
  
  public func activate(workbench: Workbench) {

  }
  
  public func deactivate() {
    
  }
  
  private func loadCustomFonts() {
    var fonts: [String] = []
    
    let bundle = Bundle(for: type(of: self))
    fonts.append(contentsOf: bundle.paths(forResourcesOfType: ".otf", inDirectory: "Fonts"))
    fonts.append(contentsOf: bundle.paths(forResourcesOfType: ".ttf", inDirectory: "Fonts"))
    
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
