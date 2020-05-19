//
//  BuildSystemIcons.swift
//  BuildSystem.plugin
//
//  Created by Danil Kristalev on 18.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import NimbleCore
import Cocoa

public class BuildSystemIcons {
  private static func icon(name: String) -> Icon {
    let image = SVGImage(svg: Bundle.main.resources/"Icons/BuildSystem/\(name).svg")
    let imageLight = SVGImage(svg:  Bundle.main.resources/"Icons/BuildSystem/\(name)-light.svg")
    
    return Icon(image: image, light: imageLight)
  }
}

public extension BuildSystemIcons {
  public static let mac = icon(name: "macIcon")
}
