//
//  CodeEditor.swift
//  CodeEditor
//
//  Created by Grigory Markin on 13.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore


public final class CodeEditor: Module {
  public static var pluginClass: Plugin.Type = CodeEditorPlugin.self
}


open class CodeEditorPlugin: Plugin {
  required public init() {
    DocumentManager.shared.registerDocumentClass(SourceCodeDocument.self)
    ThemeManager.shared.loadDefaultDarkTheme()
    SyntaxManager.shared.loadSwiftSyntax()
  }
  
  public func activate(workbench: Workbench) {

  }
  
  public func deactivate() {
    
  }
}
