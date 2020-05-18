//
//  BuildSystemIcons.swift
//  BuildSystem.plugin
//
//  Created by Danil Kristalev on 18.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import NimbleCore
import Cocoa

class BuildSystemIcons {
  private static func icon(name: String) -> Icon {
    let image = SVGImage(svg: Bundle(for: BuildSystemIcons.self).resources/"Icons/\(name).svg")
    let imageLight = SVGImage(svg: Bundle(for: BuildSystemIcons.self).resources/"Icons/\(name)-light.svg")
    
    return Icon(image: image, light: imageLight)
  }
}

extension BuildSystemIcons {
  public static let mac = icon(name: "macIcon")
}
