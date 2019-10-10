//
//  NSViewExtensions.swift
//  CYaml
//
//  Created by Danil Kristalev on 10/10/2019.
//

import Cocoa

extension NSView {
  
  public func setBackgroundColor(_ color: NSColor) {
    if self.layer == .none {
      self.layer = CALayer()
    }
    self.layer?.backgroundColor = color.cgColor
  }
  
}
