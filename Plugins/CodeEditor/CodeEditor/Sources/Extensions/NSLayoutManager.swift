//
//  NSLayoutManager.swift
//  CodeEditor.plugin
//
//  Created by Grigory Markin on 04.06.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa

extension NSLayoutManager {
  private var defaultLineHeight: CGFloat {
    guard let font = self.firstTextView?.font else { return 1.5 }
    return defaultLineHeight(for: font)
  }

  private var defaultBaselineOffset: CGFloat {
    guard let font = self.firstTextView?.font else { return 0 }
    return defaultBaselineOffset(for: font)
  }

  var spaceWidth: CGFloat {
    guard let font = self.firstTextView?.font else { return 0 }
    let spaceWidth = " ".size(withAttributes: [NSAttributedString.Key.font: font]).width
    return spaceWidth
  }

  var lineHeight: CGFloat {
    let multiple = firstTextView?.defaultParagraphStyle?.lineHeightMultiple ?? 1.0
    return multiple * defaultLineHeight
  }
}

