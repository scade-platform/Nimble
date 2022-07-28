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
import Combine
import Collections

struct EditorTabItem: Hashable {
  let document: Document

  func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }

  var title: String {
    document.title
  }

  var path: String {
    document.path?.string ?? title
  }

  var iconImage: NSImage? {
    document.icon?.image
  }

  var isEdited: Bool {
    document.isDocumentEdited
  }

  init(document: Document) {
    self.document = document
  }

  static func ==(lhs: EditorTabItem, rhs: EditorTabItem) -> Bool {
    lhs.path == rhs.path
  }
}


final class TabbedEditorViewModel {
  private var currentEditorTabIndexSubject =  CurrentValueSubject<Int?, Never>(nil)
  private var editorTabItemsSubject =  CurrentValueSubject<OrderedSet<EditorTabItem>, Never>([])

  var currentEditorTabIndex: Int? {
    get {
      currentEditorTabIndexSubject.value
    }
    set {
      currentEditorTabIndexSubject.value = newValue
    }
  }

  var editorTabItems: OrderedSet<EditorTabItem> {
    get {
      editorTabItemsSubject.value
    }
    set {
      editorTabItemsSubject.value = newValue
    }
  }

  var currentEditorTabIndexPublisher: AnyPublisher<Int?, Never> {
    currentEditorTabIndexSubject.eraseToAnyPublisher()
  }

  var editorTabItemsPublisher: AnyPublisher<OrderedSet<EditorTabItem>, Never> {
    editorTabItemsSubject.eraseToAnyPublisher()
  }

  private var currentEditorTabItem: EditorTabItem? {
      guard let currentTabItemIndex = currentEditorTabIndex else {
        return nil
      }
      return editorTabItems[currentTabItemIndex]
  }

  func tabSize(for indexPath: IndexPath) -> NSSize {
    let editorTabItem = editorTabItems[indexPath.item]
    return EditorTab.calculateSize(for: editorTabItem)
  }

  public func open(_ document: Document, show: Bool, openNewEditor: Bool) {
    // If no document is opened, just create a new tab
    guard !editorTabItems.isEmpty else {
      addTabItem(for: document)
      return
    }
    // If the current document has to be presented create
    // a new tab or reuse the existing one
    if show {
      present(document, openNewEditor: openNewEditor)
    } else {
      // Just insert a tab but not switch to it
      addTabItem(for: document, afterCurrentTab: true, selectAfterAdd: false)
    }
    // TODO: Notify about opened document
  }

  private func addTabItem(for document: Document, afterCurrentTab: Bool = false, selectAfterAdd: Bool = true) {
    let newEditorTabItem = EditorTabItem(document: document)
    let index: Int
    if afterCurrentTab {
      guard let currentEditorTabIndex = currentEditorTabIndex else {
        return
      }
      let newIndex = currentEditorTabIndex + 1 <= editorTabItems.endIndex ? currentEditorTabIndex + 1 : editorTabItems.endIndex
      (_, index) = editorTabItems.insert(newEditorTabItem, at: newIndex)
    } else {
      (_, index) = editorTabItems.append(newEditorTabItem)
    }
    if selectAfterAdd {
      currentEditorTabIndex = index
    }
  }

  private func present(_ document: Document, openNewEditor: Bool) {
    let documentTabItem = EditorTabItem(document: document)
    // If the doc is already opened, switch to its tab
    if let documentTabIndex = editorTabItems.firstIndex(of: documentTabItem) {
      currentEditorTabIndex = documentTabIndex
      return
    }
    // Insert a new tab for edited or newly created documents
    // and if it's forced by the flag 'openNewEditor'
    if let currentTabItem = currentEditorTabItem {
      if openNewEditor || currentTabItem.isEdited || currentTabItem.document.fileURL == nil {
        addTabItem(for: document, afterCurrentTab: true)
      }
    } else {
      // Show in the current tab
      guard let index = currentEditorTabIndex else { return }
      editorTabItems.update(documentTabItem, at: index)
      // TODO: Notify about close document
    }
  }

  public func close(_ document: Document) -> Bool {
    let shouldClose: Bool = document.close()

    if shouldClose {
        removeTabItem(with: document)
    }
    return shouldClose

  }

  private func removeTabItem(with document: Document) {
    let documentTabItem = EditorTabItem(document: document)
    guard let documentTabIndex = editorTabItems.firstIndex(of: documentTabItem) else {
      return
    }
    editorTabItems.remove(at: documentTabIndex)
  }
}
