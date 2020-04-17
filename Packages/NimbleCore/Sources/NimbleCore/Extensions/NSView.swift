//
//  NSViewExtensions.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 10/10/2019.
//

import Cocoa

extension NSView {
  /// TODO: get rid of this method, some specific NSViews have their own background properties
  /// and this method confuses as calling it does not make what it's expected in such cases
  public func setBackgroundColor(_ color: NSColor) {
    let current = NSAppearance.current
    NSAppearance.current =  NSApp.appearance //self.effectiveAppearance

    if self.layer == .none {
      self.layer = CALayer()
    }
    self.layer?.backgroundColor = color.cgColor

    NSAppearance.current = current

  }  
}
