//
//  TabbedEditor.swift
//  Nimble
//
//  Created by Danil Kristalev on 16.06.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Foundation
import AppKit

final class TabbedEditor: NSViewController {
  @IBOutlet private weak var tabsCollectionView: NSCollectionView!
  @IBOutlet private weak var editorContainerView: NSView!
  @IBOutlet private weak var collectionViewScrollView: NSScrollView!

  var viewModel: TabbedEditorViewModel!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupTabCollectionView()
  }

  private func setupTabCollectionView() {
    self.tabsCollectionView.backgroundColors = [.clear]

    self.tabsCollectionView.register(EditorTab.self, forItemWithIdentifier: EditorTab.itemId)

    self.tabsCollectionView.delegate = self
    self.tabsCollectionView.dataSource = self

    self.tabsCollectionView.reloadData()
  }
}

// MARK: - TabbedEditor + NSCollectionViewDelegate

extension TabbedEditor: NSCollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    print("Size: \(indexPath.item)")
    return NSSize(width: 200, height: 30)
  }
}

// MARK: - TabbedEditor + NSCollectionViewDataSource

extension TabbedEditor: NSCollectionViewDataSource {
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    viewModel.numberOfSections
  }

  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.numberOfTabs
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    print("Object: \(indexPath.item)")
    let item = collectionView.makeItem(withIdentifier: EditorTab.itemId, for: indexPath)
    guard let editorTab = item as? EditorTab else {
      return item
    }
    viewModel.setup(tab: editorTab, for: indexPath)
    return editorTab
  }

}
