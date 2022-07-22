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
    loadTabs()
  }

  private func setupTabsCollectionView() {
    self.tabsCollectionView.backgroundColors = [.clear]
    self.tabsCollectionView.register(EditorTab.self, forItemWithIdentifier: EditorTab.reuseIdentifier)
    self.tabsCollectionView.delegate = self
    self.tabsCollectionView.registerForDraggedTypes([.tabDragType])
  }

  private func loadTabs() {
    self.dataSource = self.makeDataSource()

    var snapshot = NSDiffableDataSourceSnapshot<Section, EditorTabItem>()
    snapshot.appendSections([.tabs])
    snapshot.appendItems(viewModel.editorTabItems)
    self.dataSource.apply(snapshot, animatingDifferences: false)
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
      editorTab.item = editorTabItem
      return editorTab
    })
  }

}

// MARK: - TabbedEditor + NSCollectionViewDelegate

extension TabbedEditor: NSCollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    viewModel.tabSize(for: indexPath)
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
    dataSource.apply(draggingSnapshot, animatingDifferences: true) { [weak self] in
      self?.indexPathsOfItemBeingDragged = indexPathOfDraggingItemAfterDrop
      self?.isDragAnimating = false
    }
  }
}
