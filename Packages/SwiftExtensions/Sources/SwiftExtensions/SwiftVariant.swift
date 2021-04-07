//
//  SwiftVariant.swift
//  
//
//  Created by Alexander Esilevich on 27.05.2020.
//  Copyright © 2020 Scade. All rights reserved.
//

import BuildSystem

public protocol SwiftVariant: Variant {
  var toolchain: SwiftToolchain? { get }
}

