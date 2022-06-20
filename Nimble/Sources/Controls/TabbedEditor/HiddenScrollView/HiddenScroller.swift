//
//  HiddenScrollView.swift
//  Nimble
//
//  Created by Danil Kristalev on 20.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import AppKit

class HiddenScroller: NSScroller {
  // let NSScroller tell NSScrollView that its own width is 0, so that it will not really occupy the drawing area.
  override class func scrollerWidth(for controlSize: ControlSize, scrollerStyle: Style) -> CGFloat {
    0
  }
}
