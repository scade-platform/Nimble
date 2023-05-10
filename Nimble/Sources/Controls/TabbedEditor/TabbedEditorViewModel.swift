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
  private let id: String
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  var title: String {
    return isEdited ? "*\(document.title)" : document.title
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
    if let path = document.path {
      id = path.string
    } else {
      id = UUID().description
    }
  }
  
  static func ==(lhs: EditorTabItem, rhs: EditorTabItem) -> Bool {
    lhs.id == rhs.path
  }
}

protocol TabbedEditorResponder {
  func documentDidOpen(_ document: Document)
  func documentDidClose(_ document: Document)
  func currentDocumentWillChange(_ document: Document?)
  func currentDocumentDidChange(_ document: Document?)
  func documentUpdates()
}


final class TabbedEditorViewModel {
  private let editorTabItemsSubject = CurrentValueSubject<OrderedSet<EditorTabItem>, Never>([])
  private let currentTabIndexSubject = CurrentValueSubject<Int?, Never>(nil)
  private var observingFileByPath: [Path: File] = [:]
  
  var editorTabItemsPublisher: AnyPublisher<[EditorTabItem], Never> {
    editorTabItemsSubject.map(\.elements).eraseToAnyPublisher()
  }
  
  var currentTabIndexPublisher: AnyPublisher<Int?, Never> {
    currentTabIndexSubject.eraseToAnyPublisher()
  }
  
  var currentDocumentPublisher: AnyPublisher<Document?, Never>
  private let responder: TabbedEditorResponder
  
  var currentDocument: Document? {
    let editorTabItems = editorTabItemsSubject.value
    let currentIndex = currentTabIndexSubject.value
    guard let index = currentIndex,
          !editorTabItems.isEmpty,
          index >= editorTabItems.startIndex,
          index < editorTabItems.endIndex else {
      return nil
    }
    return editorTabItems[index].document
  }
  
  var documents: [Document] {
    editorTabItemsSubject.value.elements.map { $0.document }
  }
  
  init(responder: TabbedEditorResponder) {
    self.responder = responder
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
    observeFile(of: document)
    guard !editorTabItems.isEmpty else {
      addTabItem(for: document)
      responder.documentDidOpen(document)
      return
    }
    // If the current document has to be presented create
    // a new tab or reuse the existing one
    if show {
      present(document, openNewEditor: openNewEditor)
    } else {
      // Just insert a tab but not switch to it
      addTabItem(for: document, afterCurrentTab: true, selectAfterAdd: show)
    }
    responder.documentDidOpen(document)
  }
  
  private func observeFile(of document: Document) {
    guard let path = document.path,
          observingFileByPath[path] == nil,
          let file = File(path: path)
    else {
      return
    }
    file.observers.add(observer: self)
    observingFileByPath[path] = file
  }
  
  private func addTabItem(for document: Document, afterCurrentTab: Bool = false, selectAfterAdd: Bool = true) {
    let newEditorTabItem = EditorTabItem(document: document)
    var editorTabItems = editorTabItemsSubject.value
    let index: Int
    if let documentTabIndex = editorTabItems.firstIndex(of: newEditorTabItem) {
      currentDocumentWillChange(currentDocument)
      currentTabIndexSubject.value = documentTabIndex
      currentDocumentDidChange(currentDocument)
      return
    }
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
      currentDocumentWillChange(currentDocument)
      currentTabIndexSubject.value = index
      currentDocumentDidChange(currentDocument)
    } else {
      if editorTabItems.endIndex > index + 1 {
        self.currentTabIndexSubject.value = index + 1
      } else {
        self.currentTabIndexSubject.value = index
      }
    }
  }
  
  private func present(_ document: Document, openNewEditor: Bool) {
    let documentTabItem = EditorTabItem(document: document)
    var editorTabItems = editorTabItemsSubject.value

    // If the doc is already opened, switch to its tab
    if let documentTabIndex = editorTabItems.firstIndex(of: documentTabItem) {
      currentDocumentWillChange(currentDocument)
      currentTabIndexSubject.value = documentTabIndex
      currentDocumentDidChange(currentDocument)
      return
    }

    if let currentTabItemIndex = currentTabIndexSubject.value {
      let currentTabItem = editorTabItems[currentTabItemIndex]

      // Insert a new tab for edited or newly created documents
      // and if it's forced by the flag 'openNewEditor'
      if openNewEditor || currentTabItem.isEdited || currentTabItem.document.fileURL == nil {
        addTabItem(for: document, afterCurrentTab: true)

      // Otherwise reuse the existing tab
      } else if let index = currentTabIndexSubject.value  {
        let oldItem = editorTabItems.remove(at: index)

        // If current document should be closed, reuse the tab
        if oldItem.document.close() {
          currentDocumentWillChange(currentDocument)

          editorTabItems.insert(documentTabItem, at: index)
          editorTabItemsSubject.value = editorTabItems
          currentTabIndexSubject.value = index

          responder.documentDidClose(oldItem.document)
          stopFileObserving(for: oldItem.document)

          currentDocumentDidChange(currentDocument)
        // Otherwise add a new one
        } else {
          addTabItem(for: document, afterCurrentTab: true)
        }

/*
        let oldItem = editorTabItems.remove(at: index)
        editorTabItems.insert(documentTabItem, at: index)
        editorTabItemsSubject.value = editorTabItems
        currentDocumentWillChange(currentDocument)
        currentTabIndexSubject.value = index
        currentDocumentDidChange(currentDocument)
        responder.documentDidClose(oldItem.document)
 */
      }
    }
  }
  
  public func close(_ document: Document) -> Bool {
    let editorTabItems = editorTabItemsSubject.value
    guard let index = editorTabItems.firstIndex(where: { $0.document.path == document.path }) else {
      return false
    }
    return closeTab(at: index)
  }

  @discardableResult
  public func closeTab(at index: Int) -> Bool {
    return closeTab(at: IndexPath(item: index, section: 0))
  }

  @discardableResult
  public func closeTab(at index: IndexPath) -> Bool {
    var editorTabItems = editorTabItemsSubject.value
    let removedItem = editorTabItems.remove(at: index.item)

    if removedItem.document.close() {
      responder.currentDocumentWillChange(currentDocument)
      editorTabItemsSubject.send(editorTabItems)
      if index.item < editorTabItems.endIndex {
        currentTabIndexSubject.value = index.item
      } else if index.item - 1 >= 0 {
        currentTabIndexSubject.value = index.item - 1
      } else {
        currentTabIndexSubject.value = nil
      }
      responder.documentDidClose(removedItem.document)
      stopFileObserving(for: removedItem.document)
      responder.currentDocumentDidChange(currentDocument)

      return true
    }
    return false
  }
  
  private func stopFileObserving(for document: Document) {
    guard let path = document.path, let file = observingFileByPath[path] else {
      return
    }
    file.observers.remove(observer: self)
    observingFileByPath[path] = nil
  }
  
  public func selectTab(at indexPath: IndexPath?) {
    currentDocumentWillChange(currentDocument)
    currentTabIndexSubject.value = indexPath?.item
    currentDocumentDidChange(currentDocument)
  }
  
  public func updateData(_ items: [EditorTabItem])  {
    editorTabItemsSubject.value = OrderedSet(items)
  }
  
  public func refreshTabs() {
    editorTabItemsSubject.value = editorTabItemsSubject.value
    currentTabIndexSubject.value = currentTabIndexSubject.value
  }
  
  func currentDocumentWillChange(_ document: Document?) {
    document?.observers.remove(observer: self)
    responder.currentDocumentWillChange(document)
  }
  
  func currentDocumentDidChange(_ document: Document?) {
    document?.observers.add(observer: self)
    responder.currentDocumentDidChange(document)
  }
}

extension TabbedEditorViewModel: DocumentObserver {
  func documentDidChange(_ document: Document) {
    refreshTabs()
  }
}

extension TabbedEditorViewModel: FileObserver {
  func fileDidChange(_ file: NimbleCore.File) {
    // do nothing
  }
  
  func fileDidMoved(_ file: File, newPath: Path) {
    let oldPath = file.path
    var editorTabItems = editorTabItemsSubject.value
    guard let removedIndex = editorTabItems.firstIndex(where: { $0.path == oldPath.string }) else {
      return
    }
    NSDocumentController.shared.openDocument(withContentsOf: newPath.url, display: false) { [weak self] doc, _, _ in
      guard let renamedDocument = doc as? Document else { return }
      guard let self = self else { return }
      let selectAfterReplace = removedIndex == self.currentTabIndexSubject.value
      let removedItem = editorTabItems.remove(at: removedIndex)
      removedItem.document.close()
      self.stopFileObserving(for: removedItem.document)
      self.observeFile(of: renamedDocument)
      let newDocumentTabItem = EditorTabItem(document: renamedDocument)
      do {
        let oldDocData =  try removedItem.document.data(ofType: "public.text")
        try renamedDocument.read(from: oldDocData, ofType: "public.text")
      } catch {
        return
      }
      let newIndex = removedIndex <= editorTabItems.endIndex ? removedIndex : editorTabItems.endIndex
      editorTabItems.insert(newDocumentTabItem, at: newIndex)
      self.editorTabItemsSubject.value = editorTabItems
      if selectAfterReplace {
        self.currentTabIndexSubject.value = removedIndex
      } else {
        self.currentTabIndexSubject.value = self.currentTabIndexSubject.value
      }
      self.responder.documentUpdates()
    }
  }
}
