//
//  RootSplitView.swift
//  Nimble
//
//  Created by Danil Kristalev on 13/12/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class RootSplitView: NSSplitViewController {
  //disable resizing
  override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
    return .zero
  }
}


