//
//  EditorSplitView.swift
//  Nimble
//
//  Created by Danil Kristalev on 16/12/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

class EditorSplitView: NSSplitView {
  override var dividerThickness: CGFloat {
    return self.arrangedSubviews.filter { !isSubviewCollapsed($0) }.count > 1 ? 3 : 0
  }
}
