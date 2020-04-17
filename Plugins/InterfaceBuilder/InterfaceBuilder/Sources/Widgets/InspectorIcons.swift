//
//  InspectorIcons.swift
//  InterfaceBuilder
//
//  Created by Danil Kristalev on 17.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import NimbleCore
import Cocoa


class InspectorIcons {
  private static func icon(name: String) -> Icon {
    let image = SVGImage(svg: Bundle(for: InspectorIcons.self).resources/"Icons/\(name).svg")
    let imageLight = SVGImage(svg: Bundle(for: InspectorIcons.self).resources/"Icons/\(name)-light.svg")
    
    return Icon(image: image, light: imageLight)
  }
}

extension InspectorIcons {
  public static let arrowUp = icon(name: "up")
  public static let arrowDown = icon(name: "down")
  public static let arrowUpDown = icon(name: "upDown")
}
