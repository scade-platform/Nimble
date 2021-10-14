//
//  SyntaxColoring.swift
//  CodeEditorCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

import Cocoa
import NimbleCore


public struct SyntaxColorSettings {
  var scopes: [ScopeColorSetting]
  
}

public struct ScopeColorSetting {
  fileprivate weak var settings: ColorSettings!
  
  public var name: String {settings.parameters["name", default: ""]}

  public var scope: SyntaxScope {SyntaxScope(settings.parameters["scope"] ?? "")}

  public var foreground: NSColor? {settings.color("foreground")}

  public var background: NSColor? {settings.color("background")}

  public var fontStyle: NSFontTraitMask? { settings.fontStyle }
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
