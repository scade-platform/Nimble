//
//  NSView.swift
//  CodeEditor
//
//  Created by Grigory Markin on 03.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit

public enum AppleInterfaceStyle {
  case light, dark
}

public extension NSView {
  static var systemInterfaceStlye: AppleInterfaceStyle {
    let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? ""
    return style == "Dark" ? .dark : .light
  }
}

