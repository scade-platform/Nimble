//
//  EditorView.swift
//  Nimble
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
import NimbleCore

class EditorView: NSViewController {
  var tabbedEditorViewModel: TabbedEditorViewModel? {
    didSet {
      guard let viewModel = tabbedEditorViewModel else { return }
      tabbedEditor.viewModel = viewModel
    }
  }

  lazy var tabbedEditor: TabbedEditor = {
    return TabbedEditor.loadFromNib()
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func showEditor() {
    guard tabbedEditor.parent != self else { return }

    addChild(tabbedEditor)
    view.addSubview(tabbedEditor.view)

    tabbedEditor.view.frame.size = view.frame.size
    tabbedEditor.view.layoutSubtreeIfNeeded()
  }
  
  func hideEditor() {
    tabbedEditor.removeFromParent()
    tabbedEditor.view.removeFromSuperview()
  }
}
