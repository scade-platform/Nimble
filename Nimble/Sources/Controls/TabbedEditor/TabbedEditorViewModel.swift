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
  private var openedDocuments: [Document] = []
  private var currentDocument: Document? = nil

  var numberOfTabs: Int {
    10
  }

  var numberOfSections: Int {
    1
  }

  func setup(tab: EditorTab, for indexPath: IndexPath) {
//    let editorTabModel = EditorTabModel(document: openedDocuments[indexPath.item])
    let editorTabModelMock = EditorTabModel(title: "Document\(indexPath.item)", icon: nil)
    tab.model = editorTabModelMock
  }

  func tabSize(for indexPath: IndexPath) -> NSSize {
    let editorTabModelMock = EditorTabModel(title: "Document\(indexPath.item)")
    return EditorTab.calculateSize(for: editorTabModelMock)
  }

  private func findOpenedDocument(_ document: Document) -> Int? {
    let docType = type(of: document)

    return openedDocuments.firstIndex {
      if type(of: $0) == docType {
        guard let p1 = $0.path, let p2 = document.path else { return false }
        return p1 == p2
      }
      return false
    }
  }
}
