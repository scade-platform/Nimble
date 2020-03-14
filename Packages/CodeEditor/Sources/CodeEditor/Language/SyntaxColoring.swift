//
//  SyntaxColoring.swift
//  CodeEditorCore
//
//  Created by Grigory Markin on 13.03.20.
//

import Cocoa
import NimbleCore


public struct SyntaxColorSettings {
  var scopes: [ScopeColorSetting]
  
}

public struct ScopeColorSetting {
  fileprivate weak var settings: ColorSettings!
  
  public var name: String {settings.parameters["name", default: ""]}
  public var scope: SyntaxScope {SyntaxScope(settings.parameters["scope"] ?? "")}
  
  public var fontStyle: String? {settings.settings["fontStyle", default: ""]}
  public var foreground: NSColor? {settings.color("foreground")}
  public var background: NSColor? {settings.color("background")}
}


public extension Theme {
  var scopes: [ScopeColorSetting] {
    return  settings.compactMap {
      return !$0.parameters.isEmpty ? ScopeColorSetting(settings: $0) : nil
    }
  }
  
  func setting(for scope: SyntaxScope) -> ScopeColorSetting? {
    var res: ScopeColorSetting? = nil
    for s in scopes where s.scope.contains(scope) {
      guard let rs = res?.scope else { res = s; continue }
      if rs.value.count < s.scope.value.count {
        res = s
      }
    }
    return res
  }
}
