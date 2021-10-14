//
//  NSLayoutManager.swift
//  CodeEditor.plugin
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

