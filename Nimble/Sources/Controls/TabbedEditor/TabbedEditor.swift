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

  // Queue you use to read and writing file promises.
  private var filePromiseQueue: OperationQueue = {
      let queue = OperationQueue()
      return queue
  }()

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
    snapshot.appendItems(viewModel.editorTabItems())
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

    let provider = FilePromiseProvider(fileType: "public.data", delegate: self)
    guard dataSource.itemIdentifier(for: IndexPath(item: indexPath.item, section: 0)) != nil else {
      return provider
    }
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: indexPath, requiringSecureCoding: false)
      provider.userInfo = [FilePromiseProvider.UserInfoKeys.indexPathKey: data]
    } catch {
      fatalError("failed to archive indexPath to pasteboard")
    }
    return provider
  }

  func collectionView(_ collectionView: NSCollectionView,
                      validateDrop draggingInfo: NSDraggingInfo,
                      proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
                      dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
    return [.move]
  }

  func collectionView(_ collectionView: NSCollectionView,
                      acceptDrop draggingInfo: NSDraggingInfo,
                      indexPath: IndexPath,
                      dropOperation: NSCollectionView.DropOperation) -> Bool {
      if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == tabsCollectionView {
          dropInternalTabs(collectionView, draggingInfo: draggingInfo, indexPath: indexPath)
      }
      return true
  }

  func dropInternalTabs(_ collectionView: NSCollectionView, draggingInfo: NSDraggingInfo, indexPath: IndexPath) {
      var snapshot = self.dataSource.snapshot()

      draggingInfo.enumerateDraggingItems(
          options: NSDraggingItemEnumerationOptions.concurrent,
          for: collectionView,
          classes: [NSPasteboardItem.self],
          searchOptions: [:],
          using: {(draggingItem, idx, stop) in
              if let pasteboardItem = draggingItem.item as? NSPasteboardItem {
                  do {
                      if let indexPathData = pasteboardItem.data(forType: .tabDragType), let editorTabIndexPath =
                          try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(indexPathData) as? IndexPath {
                              if let editorTabItem = self.dataSource.itemIdentifier(for: editorTabIndexPath) {
                                  // Find out the proper indexPath drop point.
                                  let dropItemLocation = snapshot.itemIdentifiers[indexPath.item]
                                  if indexPath.item == 0 {
                                      // Item is being dropped at the beginning.
                                      snapshot.moveItem(editorTabItem, beforeItem: dropItemLocation)
                                  } else {
                                      // Item is being dropped between items or at the very end.
                                      snapshot.moveItem(editorTabItem, afterItem: dropItemLocation)
                                  }
                              }
                          }
                  } catch {
                      Swift.debugPrint("failed to unarchive indexPath for dropped photo item.")
                  }
              }
          })
      dataSource.apply(snapshot, animatingDifferences: true)
  }
}

// MARK: - NSFilePromiseProviderDelegate

extension TabbedEditor: NSFilePromiseProviderDelegate {
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        // Return the photoItem's URL file name.
        let editorTabItem = editorTabFromFilePromiserProvider(filePromiseProvider: filePromiseProvider)
      return (editorTabItem?.title)!
    }

    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider,
                             writePromiseTo url: URL,
                             completionHandler: @escaping (Error?) -> Void) {
      completionHandler(nil)
    }

    func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
        return filePromiseQueue
    }

    func editorTabFromFilePromiserProvider(filePromiseProvider: NSFilePromiseProvider) -> EditorTabItem? {
        var returnEditorTab: EditorTabItem?
        if let userInfo = filePromiseProvider.userInfo as? [String: AnyObject] {
            do {
                if let indexPathData = userInfo[FilePromiseProvider.UserInfoKeys.indexPathKey] as? Data {
                    if let indexPath =
                        try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(indexPathData) as? IndexPath {
                            returnEditorTab = dataSource.itemIdentifier(for: indexPath)
                        }
                }
            } catch {
                fatalError("failed to unarchive indexPath from promise provider.")
            }
        }
        return returnEditorTab
    }

}

