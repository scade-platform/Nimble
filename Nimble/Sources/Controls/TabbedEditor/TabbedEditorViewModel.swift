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
  private let editorTabItemsSubject = CurrentValueSubject<OrderedSet<EditorTabItem>, Never>([])
  private let currentTabIndexSubject = CurrentValueSubject<Int?, Never>(nil)

  var editorTabItemsPublisher: AnyPublisher<[EditorTabItem], Never> {
    editorTabItemsSubject.map(\.elements).eraseToAnyPublisher()
  }

  var currentTabIndexPublisher: AnyPublisher<Int?, Never> {
    currentTabIndexSubject.eraseToAnyPublisher()
  }

  var currentDocumentPublisher: AnyPublisher<Document?, Never>

  init() {
    currentDocumentPublisher = editorTabItemsSubject.combineLatest(currentTabIndexSubject)
      .map { (tabs, index) -> Document? in
        guard let index = index,
              !tabs.isEmpty,
              index >= tabs.startIndex,
              index < tabs.endIndex else {
          return nil
        }
        return tabs[index].document
      }
      .eraseToAnyPublisher()
  }

  func tabSize(for indexPath: IndexPath) -> NSSize {
    let editorTabItems = editorTabItemsSubject.value
    let editorTabItem = editorTabItems[indexPath.item]
    return EditorTab.calculateSize(for: editorTabItem)
  }

  public func open(_ document: Document, show: Bool, openNewEditor: Bool) {
    let editorTabItems = editorTabItemsSubject.value
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
    var editorTabItems = editorTabItemsSubject.value
    let index: Int
    if afterCurrentTab {
      guard let currentEditorTabIndex = currentTabIndexSubject.value else {
        return
      }
      let newIndex = currentEditorTabIndex + 1 <= editorTabItems.endIndex ? currentEditorTabIndex + 1 : editorTabItems.endIndex
      (_, index) = editorTabItems.insert(newEditorTabItem, at: newIndex)
    } else {
      (_, index) = editorTabItems.append(newEditorTabItem)
    }
    editorTabItemsSubject.value = editorTabItems
    if selectAfterAdd {
      currentTabIndexSubject.value = index
    }
  }

  private func present(_ document: Document, openNewEditor: Bool) {
    let documentTabItem = EditorTabItem(document: document)
    var editorTabItems = editorTabItemsSubject.value
    // If the doc is already opened, switch to its tab
    if let documentTabIndex = editorTabItems.firstIndex(of: documentTabItem) {
      currentTabIndexSubject.value = documentTabIndex
      return
    }
    // Insert a new tab for edited or newly created documents
    // and if it's forced by the flag 'openNewEditor'
    if let currentTabItemIndex = currentTabIndexSubject.value {
      let currentTabItem = editorTabItems[currentTabItemIndex]
      if openNewEditor || currentTabItem.isEdited || currentTabItem.document.fileURL == nil {
        addTabItem(for: document, afterCurrentTab: true)
      }
    } else {
      // Show in the current tab
      guard let index = currentTabIndexSubject.value else { return }
      editorTabItems.update(documentTabItem, at: index)
      editorTabItemsSubject.value = editorTabItems
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
    var editorTabItems = editorTabItemsSubject.value
    guard let documentTabIndex = editorTabItems.firstIndex(of: documentTabItem) else {
      return
    }
    editorTabItems.remove(at: documentTabIndex)
    editorTabItemsSubject.value = editorTabItems
  }

  public func closeTab(at index: IndexPath) {
    var editorTabItems = editorTabItemsSubject.value
    editorTabItems.remove(at: index.item)
    editorTabItemsSubject.send(editorTabItems)
    if index.item < editorTabItems.endIndex {
      currentTabIndexSubject.value = index.item
    } else if index.item - 1 >= 0 {
      currentTabIndexSubject.value = index.item - 1
    } else {
      currentTabIndexSubject.value = nil
    }
  }

  public func selectTab(at indexPath: IndexPath?) {
    currentTabIndexSubject.value = indexPath?.item
  }

  public func updateData(_ items: [EditorTabItem])  {
    editorTabItemsSubject.value = OrderedSet(items)
  }
}
