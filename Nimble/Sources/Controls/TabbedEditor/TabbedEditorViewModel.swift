//
//  TabbedEditorViewModel.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Foundation
import NimbleCore
import AppKit

final class TabbedEditorViewModel {

  var editorTabItems: [EditorTabItem] = (0 ..< 10).map { EditorTabItem(title: "Document\($0)", icon: nil) }

  func tabSize(for indexPath: IndexPath) -> NSSize {
    let editorTabModelMock = editorTabItems[indexPath.item]
    return EditorTab.calculateSize(for: editorTabModelMock)
  }
}
