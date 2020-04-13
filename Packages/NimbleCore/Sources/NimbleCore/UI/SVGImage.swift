//
//  SVGImage.swift
//  NimbleCore
//
//  Created by Grigory Markin on 02/04/2020.
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
  
  public convenience init(svg: Path) {
    self.init(svg: svg.url)
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
