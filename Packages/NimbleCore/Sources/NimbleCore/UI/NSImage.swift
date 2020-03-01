//
//  NSImage.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 16/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import SwiftSVG

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

  class func createSVG(from url: URL, bounds: NSRect,
                       completion: @escaping (NSImage) -> ()) {

    CALayer(svgURL: url) { layer in
      guard let btmpImgRep =
      NSBitmapImageRep(bitmapDataPlanes: nil,
                       pixelsWide: Int(bounds.width),
                       pixelsHigh: Int(bounds.height),
                       bitsPerSample: 8,
                       samplesPerPixel: 4,
                       hasAlpha: true,
                       isPlanar: false,
                       colorSpaceName: .deviceRGB,
                       bytesPerRow: 0,
                       bitsPerPixel: 0) else { return }

      guard let context = NSGraphicsContext(bitmapImageRep: btmpImgRep) else { return }

      let xScale = bounds.width / layer.boundingBox.width
      let yScale = bounds.height / layer.boundingBox.height

      context.cgContext.translateBy(x: 0, y: bounds.height)
      context.cgContext.scaleBy(x: xScale, y: -1 * yScale)

      layer.render(in: context.cgContext)

      let image = NSImage(size: bounds.size)
      image.addRepresentation(btmpImgRep)

      completion(image)
    }
  }
}
