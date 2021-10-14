//
//  CodeEditor.swift
//  CodeEditor
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

    CodeEditorSettings.register()

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
