//
//  BuildSystemIcons.swift
//  BuildSystem.plugin
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
  static let mac = icon(name: "macIcon")
}
