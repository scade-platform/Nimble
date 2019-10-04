//
//  TabbedEditorController.swift
//  Nimble
//
//  Created by Danil Kristalev on 17/07/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import AppKit
import KPCTabsControl
import NimbleCore

class TabItem {
  var title: String {
    let t = file.name
    return changed ? "*\(t)" : t
  }
  let selectable: Bool
  let viewController: NSViewController
  let file: File
  var changed: Bool
  init(file: File, viewController: NSViewController, selectable: Bool = true) {
    self.selectable = selectable
    self.viewController = viewController
    self.file = file
    self.changed = false
  }
  
}

extension TabItem: Equatable {
  static func ==(lhs: TabItem, rhs: TabItem) -> Bool {
    return lhs.title == rhs.title
  }
}

class PreviewTabItem: TabItem, СustomizableTabItem {
  var tabStyle: Style? = nil
}

struct PreviewTheme: Theme{
  let tabButtonTheme: TabButtonTheme = DefaultTabButtonTheme()
  let selectedTabButtonTheme: TabButtonTheme = SelectedTabButtonTheme(base: DefaultTabButtonTheme())
  let unselectableTabButtonTheme: TabButtonTheme = UnselectableTabButtonTheme(base: DefaultTabButtonTheme())
  let tabsControlTheme: TabsControlTheme = DefaultTabsControlTheme()
  
  fileprivate static var sharedBorderColor: NSColor { return getColorFromAsset("BorderColor", defualt: NSColor.separatorColor)}
  
  fileprivate static var sharedBackgroundColor: NSColor { return getColorFromAsset("BackgroundColor", defualt: NSColor.windowBackgroundColor) }
  
  fileprivate struct DefaultTabButtonTheme: KPCTabsControl.TabButtonTheme {
    var backgroundColor: NSColor { return PreviewTheme.sharedBackgroundColor }
    var borderColor: NSColor { return PreviewTheme.sharedBorderColor }
    var titleColor: NSColor { return getColorFromAsset("TextColor", defualt: NSColor.selectedTextColor) }
    var titleFont: NSFont { return NSFontManager.shared.convert(NSFont.systemFont(ofSize: 12), toHaveTrait: .italicFontMask) }
  }
  
  fileprivate struct SelectedTabButtonTheme: KPCTabsControl.TabButtonTheme {
    let base: DefaultTabButtonTheme
    
    var backgroundColor: NSColor { return getColorFromAsset("SelectedBackgroundColor", defualt: NSColor.white)}
    var borderColor: NSColor { return PreviewTheme.sharedBorderColor }
    var titleColor: NSColor { return getColorFromAsset("SelectedTextColor", defualt: NSColor.selectedTextColor)  }
    var titleFont: NSFont { return NSFontManager.shared.convert(NSFont.systemFont(ofSize: 12), toHaveTrait: .italicFontMask) }
  }
  
  fileprivate struct UnselectableTabButtonTheme: KPCTabsControl.TabButtonTheme {
    let base: DefaultTabButtonTheme
    
    var backgroundColor: NSColor { return base.backgroundColor }
    var borderColor: NSColor { return base.borderColor }
    var titleColor: NSColor { return base.titleColor }
    var titleFont: NSFont { return base.titleFont }
  }
  
  fileprivate struct DefaultTabsControlTheme: KPCTabsControl.TabsControlTheme {
    var backgroundColor: NSColor { return PreviewTheme.sharedBackgroundColor }
    var borderColor: NSColor { return PreviewTheme.sharedBorderColor }
  }
}

fileprivate func getColorFromAsset(_ name: String, defualt: NSColor) -> NSColor {
  return NSColor.init(named: name, bundle: Bundle.init(for: TabsControl.self)) ?? defualt
}

class TabbedEditorController: NSViewController {
  
  @IBOutlet weak var tabBar: TabsControl?
  @IBOutlet weak var tabViewContainer: NSView!
  
  var currentFile: File? {
    return currentItem?.file
  }
  
  var changedFiles: [File]? {
    return items.filter{$0.changed}.map{$0.file}
  }
  
  
  private var items = [TabItem]()
  private var previewItem : PreviewTabItem? = nil
  private var currentItem: TabItem? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBar?.style = NimbleStyle()
    tabBar?.dataSource = self
    tabBar?.delegate = self
    tabBar?.reloadTabs()
  }
  
  func addTab(tabViewController: NSViewController, file: File){
    let previewIndex: Int?
    if contains(file: file), let previewItem = previewItem, previewItem.file === file, let index = items.firstIndex(of: previewItem) {
      items.remove(at:index)
      previewIndex = index
      self.previewItem = nil
    }else{
      previewIndex = nil
    }
    guard !contains(file: file) else {
      show(file: file)
      return
    }
    let index = previewIndex ?? items.count
    let newTabItem = TabItem(file: file, viewController: tabViewController)
    items.insert(newTabItem, at: index)
    tabBar?.reloadTabs()
    tabBar?.selectItemAtIndex(index)
  }
  
  func closeTab(file: File) -> Int? {
    guard contains(file: file), let tabItem = items.first(where: {$0.file == file}), let index = items.index(of: tabItem) else {
      return nil
    }
    let item = items.remove(at: index)
    close(tabItem: item)
    tabBar?.reloadTabs()
    if !items.isEmpty {
      if index != 0 {
        tabBar?.selectItemAtIndex(index - 1)
      } else {
        tabBar?.selectItemAtIndex(0)
      }
    }
    return index
  }
  
  func closeCurrentTab(){
    guard let curItem = currentItem, checkForSave(curItem) else {
      return
    }
    closeTab(file: curItem.file)
    NimbleController.shared.currentProject?.close(file:  curItem.file.path.url)
  }
  
  private func checkForSave(_ tabItem: TabItem) -> Bool {
    if tabItem.changed {
      let result = saveDialog(question: "Do you want to save the changes you made to \(tabItem.file.name)? ", text: "Your changes will be lost if you don't save them")
      if result.save {
        if let projectDoc = NimbleController.shared.currentDocument as? ProjectDocument{
          projectDoc.save(file: tabItem.file)
        }
      }
      return result.close
    }
    return true
  }
  
  func preview(tabViewController: NSViewController, file: File) {
    guard !contains(file: file) else {
      show(file: file)
      return
    }
    let closedIndex: Int?
    if let preview = previewItem {
      closedIndex = closeTab(file: preview.file)
    }else{
      closedIndex = nil
    }
    let index = closedIndex ?? items.count
    self.previewItem = PreviewTabItem(file: file, viewController: tabViewController)
    self.previewItem?.tabStyle = NimbleStyle(theme: PreviewTheme())
    items.insert(previewItem!, at: index)
    tabBar?.reloadTabs()
    tabBar?.selectItemAtIndex(index)
  }
  
  func markTab(file: File, changed: Bool){
    guard currentItem?.file == file else {
      return
    }
    currentItem?.changed = changed
    tabBar?.reloadTabs()
  }
  
  private func contains(file: File) -> Bool {
    return items.map{$0.file}.contains(file)
  }
  
  private func show(file: File) {
    let index = items.map{$0.file}.index(of: file)
    if let index = index {
      tabBar?.selectItemAtIndex(index)
    }
    
  }
  
  private func select(tabItem: TabItem){
    if let currentItem = self.currentItem {
      close(tabItem: currentItem)
    }
    currentItem = tabItem
    tabItem.viewController.view.frame = tabViewContainer.frame
    addChild(tabItem.viewController)
    tabViewContainer.addSubview(tabItem.viewController.view)
    currentItem = tabItem
  }
  
  private func close(tabItem: TabItem) {
    tabItem.viewController.view.removeFromSuperview()
    tabItem.viewController.removeFromParent()
  }
  
  private func saveDialog(question: String, text: String) -> (save: Bool, close: Bool) {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Save")
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Don't Save")
    let result = alert.runModal()
    return (save: result == .alertFirstButtonReturn, close:  result == .alertThirdButtonReturn || result == .alertFirstButtonReturn)
  }
  
}

extension TabbedEditorController: TabsControlDataSource {
  
  func tabsControlNumberOfTabs(_ control: TabsControl) -> Int {
    return items.count
  }
  
  func tabsControl(_ control: TabsControl, itemAtIndex index: Int) -> AnyObject {
    return items[index]
  }
  
  func tabsControl(_ control: TabsControl, titleForItem item: AnyObject) -> String {
    return (item as! TabItem).title
  }
}

extension TabbedEditorController: TabsControlDelegate {
  
  func tabsControl(_ control: TabsControl, canSelectItem item: AnyObject) -> Bool {
    return (item as! TabItem).selectable
  }
  
  func tabsControl(_ control: TabsControl, didReorderItems items: [AnyObject]) {
    self.items = items.map{$0 as! TabItem}
  }
  
  func tabsControl(_ control: TabsControl, canEditTitleOfItem item: AnyObject) -> Bool {
    return false
  }
  
  func tabsControl(_ control: TabsControl, canReorderItem item: AnyObject) -> Bool {
    return true
  }
  
  
  func tabsControlDidChangeSelection(_ control: TabsControl, item: AnyObject) {
    let tabItem = (item as! TabItem)
    select(tabItem: tabItem)
  }
  
  func tabsControlWillCloseTab(_ control: TabsControl, item: AnyObject) -> Bool {
    let tabItem = (item as! TabItem)
    guard checkForSave(tabItem) else {
      return false
    }
    close(tabItem: tabItem)
    NimbleController.shared.currentProject?.close(file: tabItem.file.path.url)
    return true
  }
  
  func tabsControlDidCloseTab(_ control: TabsControl, items: [AnyObject]) {
    self.items = items.map{$0 as! TabItem}
  }
  
  
}
