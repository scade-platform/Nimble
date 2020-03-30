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
  public static let plugin: Plugin = CodeEditorPlugin()
}
 

final class CodeEditorPlugin: Plugin {
  func load() {
    DocumentManager.shared.registerDocumentClass(CodeEditorDocument.self)
    ThemeManager.shared.load(from: resources/"Themes",
                             userDirectories: [Path.applicationSupport/"Nimble"/"Themes"])
    
    loadCustomFonts()
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
