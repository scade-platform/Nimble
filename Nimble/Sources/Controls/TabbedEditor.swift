//
//  TabbedEditorController.swift
//  Nimble
//
//  Created by Danil Kristalev on 17/07/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import KPCTabsControl


// MARK: - Tab Item

class TabItem: СustomizableTabItem {
  let document: Document
  lazy var tabStyle: Style? = NimbleStyle(theme: TabTheme(self))
    
  var edited: Bool {
    return document.isDocumentEdited
  }
  
  var title: String {
    return edited ? "*\(document.title)" : document.title
  }
  
  var viewController: NSViewController? {
    return document.contentViewController
  }
  
  init(_ document: Document) {
    self.document = document
  }
  
  func close() {
    viewController?.removeFromParent()
    viewController?.view.removeFromSuperview()
  }
}


// MARK: - Tabbed Editor

class TabbedEditor: NSViewController, NimbleWorkbenchViewController {
  
  @IBOutlet weak var tabBar: TabsControl?
  @IBOutlet weak var tabViewContainer: NSView!
        
  var items: [TabItem] = []
  
  var documents: [Document] {
    return items.map {$0.document}
  }
    
  private(set) var currentItem: TabItem? = nil {
    didSet {
      guard let itemController = currentItem?.viewController else { return }
      itemController.view.frame = tabViewContainer.frame
      addChild(itemController)
      tabViewContainer.addSubview(itemController.view)
      workbench?.observers.notify {
        $0.workbenchActiveDocumentDidChange(workbench!, document: currentDocument)
      }
    }
    willSet {
      currentItem?.close()
    }
  }
  
  var currentIndex: Int? {
    guard let item = currentItem else { return nil }
    return items.firstIndex { $0 === item }
  }
  
  var currentDocument: Document? {
    return currentItem?.document
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tabBar?.style = NimbleStyle()
    tabBar?.delegate = self
    tabBar?.dataSource = self
    
    tabBar?.reloadTabs()
  }

  func show(_ doc: Document) {
    guard let index = currentIndex else { return }
    items[index] = TabItem(doc)
    tabBar?.reloadTabs()
    selectTab(index)
  }
  
  func addTab(_ doc: Document, select: Bool = true) {
    insertTab(doc, at: items.endIndex)
  }
  
  func insertTab(_ doc: Document, at pos: Int, select: Bool = true) {
    let curIndex = currentIndex
    
    items.insert(TabItem(doc), at: pos)
    doc.observers.add(observer: self)
    
    tabBar?.reloadTabs()
        
    if select {
      selectTab(pos)      
    } else if let curIndex = curIndex, curIndex >= pos {
      selectTab(curIndex + 1)
    }
  }
  
  func removeTab(_ doc: Document) {
    guard let pos = findIndex(doc) else { return }
    
    items.remove(at: pos)
    doc.observers.remove(observer: self)
    
    tabBar?.reloadTabs()
    
    if let curIndex = currentIndex {
      selectTab(curIndex)
    } else {
      if items.count > 0 {
        selectTab(pos > 0 ? pos - 1 : 0)
      } else {
        currentItem = nil
      }
    }
  }
      
  func selectTab(_ index: Int) {
    tabBar?.selectItemAtIndex(index)
  }
  
  func findIndex(_ doc: Document) -> Int? {
    return items.firstIndex {
      guard let p1 = $0.document.path, let p2 = doc.path else { return false }
      return p1 == p2
    }
  }
}

// MARK: - Document Observer

extension TabbedEditor: DocumentObserver {
  func documentDidChange(_ document: Document) {
    tabBar?.reloadTabs()
  }
}


// MARK: - Data Source

extension TabbedEditor: TabsControlDataSource {
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

extension TabbedEditor: TabsControlDelegate {
  func tabsControl(_ control: TabsControl, canSelectItem item: AnyObject) -> Bool {
    return true
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
    if let curItem = currentItem, curItem === item { return }
    currentItem = item as? TabItem
  }
  
  func tabsControlWillCloseTab(_ control: TabsControl, item: AnyObject) -> Bool {
    let item = item as! TabItem
    return workbench?.close(item.document) ?? true
  }
  
//  func tabsControlDidCloseTab(_ control: TabsControl, items: [AnyObject]) {
//    self.items = items.map {$0 as! TabItem}
//  }
}



// MARK: - Themes

struct TabTheme: Theme {
  let tabButtonTheme: TabButtonTheme = DefaultTabButtonTheme()
  let unselectableTabButtonTheme: TabButtonTheme = UnselectableTabButtonTheme(base: DefaultTabButtonTheme())
  let tabsControlTheme: TabsControlTheme = DefaultTabsControlTheme()
  
  let selectedTabButtonTheme: TabButtonTheme
  
  fileprivate static var sharedBorderColor: NSColor { return getColorFromAsset("BorderColor", defualt: NSColor.separatorColor)}
  fileprivate static var sharedBackgroundColor: NSColor { return getColorFromAsset("BackgroundColor", defualt: NSColor.windowBackgroundColor) }
  
  init(_ tabItem: TabItem?) {
    self.selectedTabButtonTheme = SelectedTabButtonTheme(base: DefaultTabButtonTheme(), tabItem: tabItem)
  }
  
  fileprivate struct DefaultTabButtonTheme: KPCTabsControl.TabButtonTheme {
    var backgroundColor: NSColor { return TabTheme.sharedBackgroundColor }
    var borderColor: NSColor { return TabTheme.sharedBorderColor }
    var titleColor: NSColor { return getColorFromAsset("TextColor", defualt: NSColor.selectedTextColor) }
    var titleFont: NSFont { return NSFontManager.shared.convert(NSFont.systemFont(ofSize: 12), toHaveTrait: .italicFontMask) }
  }
  
  fileprivate struct SelectedTabButtonTheme: KPCTabsControl.TabButtonTheme {
    let base: DefaultTabButtonTheme
    weak var tabItem: TabItem?
    
    var backgroundColor: NSColor {
//      if let tabView = tabItem?.viewController?.view,
//          let cgColor = tabView.layer?.backgroundColor,
//          let color = NSColor(cgColor: cgColor) {
//
//          return color
//      }
      return getColorFromAsset("SelectedBackgroundColor", defualt: NSColor.white)
    }
    
    var borderColor: NSColor { return TabTheme.sharedBorderColor }
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
    var backgroundColor: NSColor { return TabTheme.sharedBackgroundColor }
    var borderColor: NSColor { return TabTheme.sharedBorderColor }
  }
}

fileprivate func getColorFromAsset(_ name: String, defualt: NSColor) -> NSColor {
  return NSColor.init(named: name, bundle: Bundle.init(for: TabsControl.self)) ?? defualt
}
