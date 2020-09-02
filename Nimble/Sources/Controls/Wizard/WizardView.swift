//
//  WizardViewController.swift
//  Nimble
//
//  Created by Danil Kristalev on 26.08.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class WizardView: NSViewController {
  
  @IBOutlet weak var outline: NSOutlineView?
  
  @IBOutlet weak var lable: NSTextField?
  
  @IBOutlet weak var previouseButton: NSButton?
  @IBOutlet weak var nextButton: NSButton?
  
  @IBOutlet weak var mainTabViewItem: NSTabViewItem!
  @IBOutlet weak var tabView: NSTabView?
  
  private var currentPageIndex: Int {
    guard let tabView = tabView, let selectedItem = tabView.selectedTabViewItem else { return 0 }
    return tabView.indexOfTabViewItem(selectedItem)
  }
  
  private var selectedGenerator: Generator? {
    guard let itemIndex = outline?.selectedRow,
      let generator = outline?.item(atRow: itemIndex) as? Generator
    else {
      return nil
    }
    return generator
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    outline?.delegate = self
    outline?.dataSource = self
    outline?.reloadData()
    outline?.expandItem(GeneratorsManager.shared)
    
    self.nextButton?.isEnabled = false
    self.previouseButton?.isEnabled = false
  }
  
  
  @IBAction func canselButtonDidClick(_ sender: Any?) {
    closeWizard()
  }
  
  @IBAction func nextButtonDidClick(_ sender: Any?) {
    guard let generator = selectedGenerator else { return }
    if generator.wizardPages.isEmpty {
      generator.generate { [weak self] in
        self?.closeWizard()
      }
    } else {
      if currentPageIndex == 0 {
        setupPages(for: generator)
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
  
  private func setupPages(for generator: Generator) {
    tabView?.tabViewItems.forEach{ item in
      //remove all pages except first
      guard item != mainTabViewItem else { return }
      tabView?.removeTabViewItem(item)
    }
    
    for page in generator.wizardPages {
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
      selectedGenerator?.generate { [weak self] in
        self?.closeWizard()
      }
      return
    }
    
    //change header title
    lable?.stringValue = "Choose option for new project:"
    //open next page
    tabView!.selectTabViewItem(at: nextPageIndex)
    
    
    if currentPageIndex != 0 {
      previouseButton?.isEnabled = true
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
      lable?.stringValue = "Choose a template:"
      previouseButton?.isEnabled = false
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
    guard let item = item else { return GeneratorsManager.shared}
    switch item {
    case let manager as GeneratorsManager:
      return manager.generators[index]
    default:
      return self
    }
  }
  
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    guard let item = item else { return 1 }
    switch item {
    case let manager as GeneratorsManager:
      return manager.generators.count
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
      let _ = item as? Generator else { return }
    self.nextButton?.isEnabled = true
  }
  
  public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return item is GeneratorsManager
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
    return !(item is GeneratorsManager)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is GeneratorsManager)
  }
  
  public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    switch item {
    case let item as GeneratorsManager:
      guard let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.headerCell),
                                            owner: self) as? NSTableCellView else { return nil }
      view.textField?.stringValue = "PROJECTS"
      return view
    case let item as Generator:
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

