//
//  Bundle.swift
//  Nimble
//
//  Created by Danil Kristalev on 03.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

extension Bundle {
  func loadBottonImage(name: String) -> NSImage? {
    let color = NSColor(named: "ButtonIconColor", bundle: self) ?? .darkGray
    let icon = self.image(forResource: name)?.imageWithTint(color)
    return icon
  }
}
