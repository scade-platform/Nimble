//
//  NSColor.swift
//  
//
//  Created by Grigory Markin on 31.03.20.
//

import Cocoa

extension NSColor {
  var isDark: Bool {
    let rgb = cgColor.components!
    return (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) < 0.5
  }
}
