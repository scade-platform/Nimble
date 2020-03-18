//
//  NSImage.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 16/01/2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import SwiftSVG

public class SVGImage: NSImage {
  private var layer: SVGLayer?
  
  public convenience init(svg: URL) {
    let layer = SVGLayer.createFrom(url: svg)
    let size = layer?.viewBox?.size ?? layer?.boundingBox.size ?? NSSize()
    self.init(size: size)
    self.layer = layer
  }
    
  public override func cgImage(forProposedRect proposedDestRect: UnsafeMutablePointer<NSRect>?, context referenceContext: NSGraphicsContext?, hints: [NSImageRep.HintKey : Any]?) -> CGImage? {
    
    guard let layer = layer else { return nil }
    
    let rect = proposedDestRect!.pointee
    let scale = NSScreen.main?.backingScaleFactor ?? 1.0
    
    let width = scale * rect.size.width
    let height = scale * rect.size.height
    
    let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let context  = CGContext(data: nil, width: Int(width), height: Int(height),
                                   bitsPerComponent: 8, bytesPerRow: 0,
                                   space: colorSpace!, bitmapInfo: bitmapInfo.rawValue) else { return nil }
    
    let xScale = width / self.size.width
    let yScale = height / self.size.height

    context.translateBy(x: 0, y: height)
    context.scaleBy(x: xScale, y: -yScale)

    layer.render(in: context)
    return context.makeImage()
  }
}


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
