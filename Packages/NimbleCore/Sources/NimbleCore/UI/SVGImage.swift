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
  public var svgLayer: SVGLayer?

  private func scaling(_ rect: NSRect) -> (xScale: CGFloat, yScale: CGFloat, width: CGFloat, height: CGFloat) {
    let scale = NSScreen.main?.backingScaleFactor ?? 1.0

    let width = scale * rect.size.width
    let height = scale * rect.size.height

    let xScale = width / svgLayer!.size.width
    let yScale = height / svgLayer!.size.height

    return (xScale, yScale, width, height)
  }

  public convenience init(svg: URL) {
    let layer = SVGLayer.createFrom(url: svg)
    self.init(size: layer?.size ?? NSSize())
    self.svgLayer = layer
  }
  
  public convenience init(svg: Path) {
    self.init(svg: svg.url)
  }

  public override func draw(in rect: NSRect) {
    guard let context = NSGraphicsContext.current,
          let layer = svgLayer else { return }

    let (xScale, yScale, _, height) = scaling(rect)

    context.saveGraphicsState()
    context.cgContext.translateBy(x: 0, y: height)
    context.cgContext.scaleBy(x: xScale, y: -yScale)

    layer.render(in: context.cgContext)

    context.restoreGraphicsState()
  }

  public override func cgImage(forProposedRect proposedDestRect: UnsafeMutablePointer<NSRect>?, context referenceContext: NSGraphicsContext?, hints: [NSImageRep.HintKey : Any]?) -> CGImage? {
    
    guard let layer = svgLayer else { return nil }

    let (xScale, yScale, width, height) = scaling(proposedDestRect!.pointee)

    let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let context  = CGContext(data: nil, width: Int(width), height: Int(height),
                                   bitsPerComponent: 8, bytesPerRow: 0,
                                   space: colorSpace!, bitmapInfo: bitmapInfo.rawValue) else { return nil }

    context.translateBy(x: 0, y: height)
    context.scaleBy(x: xScale, y: -yScale)

    layer.render(in: context)

//    let cgImage = context.makeImage()
//    writeCGImage(cgImage!, to: URL(fileURLWithPath: "/Users/markin/Desktop/foo.png"))

    return context.makeImage()
  }

  @discardableResult func writeCGImage(_ image: CGImage, to destinationURL: URL) -> Bool {
      guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return false }
      CGImageDestinationAddImage(destination, image, nil)
      return CGImageDestinationFinalize(destination)
  }
}


fileprivate extension SVGLayer {
  var size: NSSize {
    return viewBox?.size ?? boundingBox.size
  }
}
