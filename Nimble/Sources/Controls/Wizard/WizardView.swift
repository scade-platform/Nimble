//
//  WizardViewController.swift
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

class WizardView: NSViewController {
  
  @IBOutlet weak var outline: NSOutlineView?
  
  @IBOutlet weak var label: NSTextField?
  
  @IBOutlet weak var previousButton: NSButton?
  @IBOutlet weak var nextButton: NSButton?
  
  @IBOutlet weak var mainTabViewItem: NSTabViewItem!
  @IBOutlet weak var tabView: NSTabView?
  
  private var currentPageIndex: Int {
    guard let tabView = tabView, let selectedItem = tabView.selectedTabViewItem else { return 0 }
    return tabView.indexOfTabViewItem(selectedItem)
  }
  
  private var selectedWizard: CreationWizard? {
    guard let itemIndex = outline?.selectedRow,
      let wizard = outline?.item(atRow: itemIndex) as? CreationWizard
    else {
      return nil
    }
    return wizard
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    outline?.delegate = self
    outline?.dataSource = self
    outline?.reloadData()
    outline?.expandItem(WizardsManager.shared)
    
    self.nextButton?.isEnabled = false
    self.previousButton?.isEnabled = false
  }
  
  
  @IBAction func canselButtonDidClick(_ sender: Any?) {
    closeWizard()
  }
  
  @IBAction func nextButtonDidClick(_ sender: Any?) {
    guard let wizard = selectedWizard else { return }
    if wizard.wizardPages.isEmpty {
      wizard.create { [weak self] in
        self?.closeWizard()
      }
    } else {
      if currentPageIndex == 0 {
        setupPages(for: wizard)
      }
      showNextPage()
    }
  }
  
  @IBAction func prevButtonDidClick(_ sender: Any?) {
    showPreviousePage()
  }
  
  private func closeWizard() {
    NSApp.stopModal()
    (self.view.window as? NSPanel)?.orderOut(nil)
  }
  
  private func setupPages(for wizard: CreationWizard) {
    tabView?.tabViewItems.forEach{ item in
      //remove all pages except first
      guard item != mainTabViewItem else { return }
      tabView?.removeTabViewItem(item)
    }
    
    for page in wizard.wizardPages {
      //realease old data
      page.clearPage()
      let tabViewItem = NSTabViewItem(identifier: nil)
      tabViewItem.view = page
      tabView?.addTabViewItem(tabViewItem)
    }
  }
  
  func showNextPage() {
    let nextPageIndex = currentPageIndex + 1
    guard nextPageIndex < tabView!.numberOfTabViewItems else {
      selectedWizard?.create { [weak self] in
        self?.closeWizard()
      }
      return
    }
    
    //change header title
    label?.stringValue = "Choose option for new project:"
    //open next page
    tabView!.selectTabViewItem(at: nextPageIndex)
    
    
    if currentPageIndex != 0 {
      previousButton?.isEnabled = true
    }
    
    //last wizard page
    if currentPageIndex == tabView!.numberOfTabViewItems - 1 {
      nextButton?.title = "Create"
    }
    
    pageChanged()
  }
  
  func showPreviousePage() {
    let previousePageIndex = currentPageIndex - 1
    guard previousePageIndex >= 0 else {
      return
    }
    
    tabView!.selectTabViewItem(at: previousePageIndex)
    nextButton?.title = "Next"
    
    //main wizard page
    if currentPageIndex == 0 {
      label?.stringValue = "Choose a template:"
      previousButton?.isEnabled = false
    }
    
    pageChanged()
  }
  
  func pageChanged() {
    guard currentPageIndex > 0 else {
      nextButton?.isEnabled = true
      return
    }
    
    if let page = tabView?.selectedTabViewItem?.view as? WizardPage {
      //Current page should be valid in order to go next step
      nextButton?.isEnabled = page.isValid
      page.validationHandler = { [weak self] isValid in
        self?.nextButton?.isEnabled = isValid
      }
    }
  }
}



extension WizardView: NSOutlineViewDataSource {
  public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    guard let item = item else { return WizardsManager.shared}
    switch item {
    case let manager as WizardsManager:
      return manager.wizards[index]
    default:
      return self
    }
  }
  
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 1 }
    switch item {
    case let manager as WizardsManager:
      return manager.wizards.count
    default:
      return 0
    }
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
  }
}

extension WizardView: NSOutlineViewDelegate {
  
  fileprivate enum CellIdentifiers {
    static let headerCell = "HeaderCellID"
    static let projectCell = "ProjectCellID"
  }
  
  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView,
      let item = outlineView.item(atRow: outlineView.selectedRow),
      let _ = item as? CreationWizard else { return }
    self.nextButton?.isEnabled = true
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return item is WizardsManager
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return !(item is WizardsManager)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is WizardsManager)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case is WizardsManager:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.headerCell),
                                            owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = "PROJECTS"
      return view
    case let item as CreationWizard:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.projectCell),
                                            owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = item.name
      view.objectValue = item
      return view
    default:
      return nil
    }
  }
}


class WizardPanel: NSPanel {
  override var canBecomeKey: Bool {
    true
  }
}

