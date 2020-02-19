//
//  NSImage.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 16/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

public extension NSImage {
  func imageWithTint(_ tint: NSColor) -> NSImage {
    var imageRect = NSZeroRect;
    imageRect.size = self.size;
    
    let highlightImage = NSImage(size: imageRect.size)
    
    highlightImage.lockFocus()
    
    self.draw(in: imageRect, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
    
    tint.set()
    imageRect.fill(using: .sourceAtop);
    
    highlightImage.unlockFocus()
    
    return highlightImage;
  }
}
