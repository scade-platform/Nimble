//
//  TabbedEditor.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Foundation
import AppKit
import NimbleCore
import Combine

extension NSPasteboard.PasteboardType {
  static let tabDragType = NSPasteboard.PasteboardType("com.scade.editorTabs")
}

final class TabbedEditor: NSViewController {
  @IBOutlet private weak var tabsCollectionView: NSCollectionView!
  @IBOutlet private weak var editorContainerView: NSView!
  @IBOutlet private weak var collectionViewScrollView: NSScrollView!

  private var indexPathsOfItemBeingDragged: IndexPath!
  private var isDragAnimating: Bool = false
  private var draggingSnapshot: NSDiffableDataSourceSnapshot<Section, EditorTabItem>!
  private var isDragging: Bool {
    draggingSnapshot != nil
  }

  private weak var currentEditorViewController: NSViewController?

  private var subscriptions: Set<AnyCancellable> = []

  var draggingEditorTabItem: EditorTabItem? {
    guard let draggingSnapshot = draggingSnapshot,
          let indexPathsOfItemBeingDragged = indexPathsOfItemBeingDragged else {
      return nil
    }
    return draggingSnapshot.itemIdentifiers[indexPathsOfItemBeingDragged.item]
  }

  var viewModel: TabbedEditorViewModel!

  enum Section {
    case tabs
  }
  var dataSource: NSCollectionViewDiffableDataSource<Section, EditorTabItem>! = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabsCollectionView()
    bindToViewModel()
  }

  private func setupTabsCollectionView() {
    self.tabsCollectionView.backgroundColors = [.clear]
    self.tabsCollectionView.register(EditorTab.self, forItemWithIdentifier: EditorTab.reuseIdentifier)
    self.tabsCollectionView.delegate = self
    self.tabsCollectionView.registerForDraggedTypes([.tabDragType])

    self.dataSource = self.makeDataSource()
    var snapshot = NSDiffableDataSourceSnapshot<Section, EditorTabItem>()
    snapshot.appendSections([.tabs])
    self.dataSource.apply(snapshot, animatingDifferences: false)
  }

  private func bindToViewModel() {
    viewModel.editorTabItemsPublisher
      .sink { [weak self] tabItems in
        guard let self = self else {
          return
        }
        guard !self.isDragging else {
          return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, EditorTabItem>()
        snapshot.appendSections([.tabs])
        snapshot.appendItems(tabItems)
        self.dataSource.apply(snapshot, animatingDifferences: false)
      }
      .store(in: &subscriptions)

    viewModel.currentTabIndexPublisher
      .sink { [ weak self] currentTabItemIndex in
        guard let self = self else {
          return
        }
        guard let index = currentTabItemIndex else {
          self.tabsCollectionView.selectItems(at: [], scrollPosition: .left)
          return
        }
        self.tabsCollectionView.deselectAll(nil)
        self.tabsCollectionView.selectItems(at: [IndexPath(item: index, section: 0)], scrollPosition: .right)
      }
      .store(in: &subscriptions)

    viewModel.currentDocumentPublisher
      .sink { [weak self] document in
        guard let self = self else {
          return
        }
        guard !self.isDragging else {
          return
        }
        guard let documentEditor = document?.editor else {
          self.currentEditorViewController?.removeFromParent()
          self.currentEditorViewController?.view.removeFromSuperview()
          self.currentEditorViewController = nil
          return
        }

        self.currentEditorViewController?.removeFromParent()
        self.currentEditorViewController?.view.removeFromSuperview()

        self.addChild(documentEditor)
        self.editorContainerView.addSubview(documentEditor.view)
        documentEditor.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate( [
          documentEditor.view.topAnchor.constraint(equalTo: self.editorContainerView.topAnchor),
          documentEditor.view.bottomAnchor.constraint(equalTo: self.editorContainerView.bottomAnchor),
          documentEditor.view.leadingAnchor.constraint(equalTo: self.editorContainerView.leadingAnchor),
          documentEditor.view.trailingAnchor.constraint(equalTo: self.editorContainerView.trailingAnchor)
        ])

        self.currentEditorViewController = documentEditor
      }
      .store(in: &subscriptions)
  }

  private func removeEditorForTabItem(at index: Int, for snapshot: NSDiffableDataSourceSnapshot<Section, EditorTabItem>) {
    guard index >= 0, index < snapshot.numberOfItems else {
      return
    }
    let tabItem = snapshot.itemIdentifiers[index] as EditorTabItem
    if let editor = tabItem.document.editor {
      editor.removeFromParent()
      editor.view.removeFromSuperview()
    }
  }
}

// MARK: - Data Source

private extension TabbedEditor {
  func makeDataSource() -> NSCollectionViewDiffableDataSource<Section, EditorTabItem> {
    return NSCollectionViewDiffableDataSource
    <Section, EditorTabItem>(collectionView: self.tabsCollectionView, itemProvider: {
      (collectionView: NSCollectionView, indexPath: IndexPath, editorTabItem: EditorTabItem) -> NSCollectionViewItem? in
      let item = collectionView.makeItem(withIdentifier: EditorTab.reuseIdentifier, for: indexPath)
      guard let editorTab = item as? EditorTab else {
        return item
      }
      editorTab.present(item: editorTabItem)
      return editorTab
    })
  }

}

// MARK: - TabbedEditor + NSCollectionViewDelegate

extension TabbedEditor: NSCollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    viewModel.tabSize(for: indexPath)
  }

  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    viewModel.selectTab(at: indexPaths.first)
  }

  // MARK: - Drag and Drop

  func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
    return true
  }

  func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
    return NSPasteboardItem(pasteboardPropertyList: [], ofType: .tabDragType)
  }

  func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
    indexPathsOfItemBeingDragged = indexPaths.first
    draggingSnapshot = self.dataSource.snapshot()
  }

  func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
    indexPathsOfItemBeingDragged = nil
    draggingSnapshot = nil
  }

  func collectionView(_ collectionView: NSCollectionView,
                      validateDrop draggingInfo: NSDraggingInfo,
                      proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
                      dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
    guard indexPathsOfItemBeingDragged != nil else {
      return []
    }
    let proposedIndexPath = proposedDropIndexPath.pointee as IndexPath
    dropInternalTabs(to: proposedIndexPath)
    return .move
  }

  func collectionView(_ collectionView: NSCollectionView,
                      acceptDrop draggingInfo: NSDraggingInfo,
                      indexPath: IndexPath,
                      dropOperation: NSCollectionView.DropOperation) -> Bool {
    return true
  }

  private func dropInternalTabs(to dropIndexPath: IndexPath) {
    guard !isDragAnimating else {
      return
    }
    guard let draggingEditorTabItem = draggingEditorTabItem else {
      return
    }
    guard indexPathsOfItemBeingDragged != dropIndexPath else {
      return
    }
    let indexPathOfDraggingItemAfterDrop: IndexPath
    if dropIndexPath.item >= draggingSnapshot.numberOfItems {
      let lastItem = draggingSnapshot.itemIdentifiers.last!
      indexPathOfDraggingItemAfterDrop = IndexPath(item: draggingSnapshot.indexOfItem(lastItem)!, section: 0)
      draggingSnapshot.moveItem(draggingEditorTabItem, afterItem: lastItem)
    } else {
      let dropItemLocation = draggingSnapshot.itemIdentifiers[dropIndexPath.item]
      indexPathOfDraggingItemAfterDrop = dropIndexPath
      if dropIndexPath.item < indexPathsOfItemBeingDragged.item {
        // Item is being dropped at the beginning.
        draggingSnapshot.moveItem(draggingEditorTabItem, beforeItem: dropItemLocation)
      } else {
        // Item is being dropped between items or at the very end.
        draggingSnapshot.moveItem(draggingEditorTabItem, afterItem: dropItemLocation)
      }
    }
    isDragAnimating = true
    viewModel.updateData(draggingSnapshot.itemIdentifiers)
    dataSource.apply(draggingSnapshot, animatingDifferences: true) { [weak self] in
      self?.indexPathsOfItemBeingDragged = indexPathOfDraggingItemAfterDrop
      self?.isDragAnimating = false
    }
  }
}

extension TabbedEditor: TabbedEditorDelegate {
  func closeTab(at index: IndexPath) {
    viewModel.closeTab(at: index)
  }
}

protocol TabbedEditorDelegate {
  func closeTab(at index: IndexPath)
}

