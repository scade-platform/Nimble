//
//  PageDocument.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import NimbleCore
import ScadeKit


public final class PageDocument: NSDocument, Document {
  private var svgRoot: SCDSvgBox?
  private var svgSize: CGSize?
  
  private lazy var builderController: InterfaceBuilderController = {
    let controller = InterfaceBuilderController.loadFromNib()
    controller.doc = self
    return controller
  }()
  
  public var contentViewController: NSViewController? { return builderController }
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
  
//  public override func read(from data: Data, ofType typeName: String) throws {
//    svgRoot = SCDRuntime.parseSvg("") as! SCDSvgBox
//  }
  
  public override func read(from url: URL, ofType typeName: String) throws {
    let resource = SCDRuntime.loadXmiResource(url.path) as! SCDCoreResource
    let resourceContents = resource.contents
    if !resourceContents.isEmpty {
      svgRoot = resourceContents[resourceContents.count - 1] as? SCDSvgBox
      if let page = resourceContents[0] as? SCDWidgetsPage {
        var width = page.size.width
        var height = page.size.height
        let minSize = page.minArea
        if minSize.width > 0 && minSize.height > 0 {
          width = minSize.width
          height = minSize.height
        }
        svgSize = CGSize(width: width, height: height)
      }
    }
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
  
  public func render() {
    if let svg = svgRoot {
      let size = getSvgSize()
      svg.width = SCDSvgUnit(value: Float(size.width))
      svg.height = SCDSvgUnit(value: Float(size.height))
      SCDRuntime.renderSvg(svg, x: 0, y: 0, size:size);
    }
  }

  public func getSvgSize() -> CGSize {
    guard let res = svgSize else {
      return CGSize(width: 0, height: 0)
    }
    return res
  }
}
