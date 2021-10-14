//
//  CodeEditorTextView+Commands.swift
//  CodeEditor
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

import CodeEditor
import Cocoa


extension CodeEditorView: WorkbenchEditorZoomSupport {

  func zoomIn() {
    zoom(delta: 1)
  }

  func zoomOut() {
    zoom(delta: -1)
  }

  func zoomActualSize() {
    guard let theme = ThemeManager.shared.currentTheme,
          let lineNumberView = self.textView.lineNumberView else { return }

    self.textView.font = theme.general.font


    lineNumberView.setFontSize(size: theme.general.font.pointSize)
    lineNumberView.setNeedsDisplay(lineNumberView.bounds)
  }

  private func zoom(delta: CGFloat) {
    self.textView.modifyFontSize(delta: delta)

    guard let lineNumberView = self.textView.lineNumberView else { return }

    lineNumberView.incrementFontSize(delta: delta)
    lineNumberView.setNeedsDisplay(lineNumberView.bounds)
  }
}
