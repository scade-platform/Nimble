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

protocol TabItem : class {
  var title: String { get }
  var viewController: NSViewController { get }
  var selectable: Bool { get }
  func isEqual(to other: TabItem) -> Bool
  var isChange: Bool {get set}
}

extension TabItem {
  var selectable: Bool {
    return true
  }
  
  var isChange: Bool {
    get {return false}
    set {}
  }
}

extension TabItem where Self: Equatable {
  func isEqual(to other: TabItem) -> Bool {
    if let otherTab = other as? Self {
      return self == otherTab
    } else if let otherTab = other as? PreviewTabItem, let wrappedTab = otherTab.wrappedTabItem as? Self  {
      return self == wrappedTab
    } else if let preview = self as? PreviewTabItem {
      return preview.wrappedTabItem.isEqual(to: other)
    } else { return false }
  }
}

class DocumentTabItem : TabItem {
  let document: Document
  
  var title: String {
    let t = document.title
    return isChange ? "*\(t)" : t
  }
  
  var isChange: Bool = false
  
  lazy var viewController: NSViewController = {
    return document.contentViewController ?? UnsupportedPane.loadFromNib()
  }()
  
  init(document: Document) {
    self.document = document
  }
}

extension DocumentTabItem: Equatable {
  static func == (lhs: DocumentTabItem, rhs: DocumentTabItem) -> Bool {
    return lhs.document === rhs.document
  }
}


class UnsupportedFileTabItem : TabItem {
  let file: File
  
  var title: String {
    return file.name
  }
  
  lazy var viewController: NSViewController = {
    return UnsupportedPane.loadFromNib()
  }()
  
  init(file: File) {
    self.file = file
  }
}

extension UnsupportedFileTabItem: Equatable {
  static func == (lhs: UnsupportedFileTabItem, rhs: UnsupportedFileTabItem) -> Bool {
    return lhs.file.path == rhs.file.path
  }
}

class PreviewTabItem: TabItem, СustomizableTabItem {
  let wrappedTabItem: TabItem
  
  lazy var tabStyle: Style? = {
    return NimbleStyle(theme: PreviewTheme())
  }()
  
  var title: String {
    return wrappedTabItem.title
  }
  
  var viewController: NSViewController {
    return wrappedTabItem.viewController
  }
  
  init(wraped tabItem: TabItem){
    self.wrappedTabItem = tabItem
    
  }
}

extension PreviewTabItem : Equatable {
  static func == (lhs: PreviewTabItem, rhs: PreviewTabItem) -> Bool {
    return lhs.wrappedTabItem.isEqual(to: rhs.wrappedTabItem)
  }
}

class TabbedEditorController: NSViewController {
  
  @IBOutlet weak var tabBar: TabsControl?
  @IBOutlet weak var tabViewContainer: NSView!
  
  private var items: [TabItem] = []
  private var previewItem : PreviewTabItem? = nil
  private var currentItem: TabItem? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBar?.style = NimbleStyle()
    tabBar?.dataSource = self
    tabBar?.delegate = self
    tabBar?.reloadTabs()
  }
}

extension TabbedEditorController {
  
  var currentDocument: Document? {
    return (currentItem as? DocumentTabItem)?.document
  }
  
  func show(usupported file: File) {
    showPreview(for: UnsupportedFileTabItem(file: file))
   }
  
  func open(document: Document, preview: Bool) {
    let newTab = DocumentTabItem(document: document)
    if preview {
      showPreview(for: newTab)
    } else {
      document.observer = self
      append(tabItem: newTab)
    }
  }
  
  func close(document: Document) {
    close(tab: DocumentTabItem(document: document))
  }
}

fileprivate extension TabbedEditorController {
  var workbench: NimbleWorkbench? {
    return self.view.window?.windowController as? NimbleWorkbench
  }
  
  func contain(tab: TabItem) -> Bool {
    return items.contains(where: {$0.isEqual(to: tab)})
  }
  
  func append(tabItem: TabItem) {
    guard !contain(tab: tabItem) else {
      if let isPreview = previewItem?.wrappedTabItem.isEqual(to: tabItem), isPreview {
        unwrapPreviewTab()
      }else {
        show(tab: tabItem)
      }
      return
    }
    add(tab: tabItem)
  }
  
  func showIfContain(tab: TabItem) -> Bool {
    guard contain(tab: tab) else {
      return false
    }
    show(tab: tab)
    return true
  }
  
  func show(tab: TabItem) {
    let index = items.firstIndex(where: {$0.isEqual(to: tab)})
    if let index = index {
      tabBar?.selectItemAtIndex(index)
    }
  }
  
  func showPreview(for tab: TabItem) {
    guard !showIfContain(tab: tab) else {
      return
    }
    let closedIndex = previewItem.flatMap{ close(tab: $0) }
    let index = closedIndex ?? items.count
    previewItem = PreviewTabItem(wraped: tab)
    items.insert(previewItem!, at: index)
    tabBar?.reloadTabs()
    tabBar?.selectItemAtIndex(index)
  }

  
  func unwrapPreviewTab() {
    guard let wrappedItem = previewItem?.wrappedTabItem else {
      return
    }
    if let index = items.firstIndex(where: {$0.isEqual(to: wrappedItem)}) {
      items.remove(at: index)
      items.insert(wrappedItem, at: index)
      previewItem = nil
      tabBar?.reloadTabs()
      tabBar?.selectItemAtIndex(index)
    }
  }
  
  func add(tab: TabItem){
    items.append(tab)
    tabBar?.reloadTabs()
    tabBar?.selectItemAtIndex(items.endIndex - 1)
  }
  
  func select(tab: TabItem){
     if let currentItem = currentItem {
       closeView(for: currentItem)
     }
     currentItem = tab
     tab.viewController.view.frame = tabViewContainer.frame
     addChild(tab.viewController)
     tabViewContainer.addSubview(tab.viewController.view)
     currentItem = tab
   }
  
  func closeView(for tab: TabItem) {
    tab.viewController.view.removeFromSuperview()
    tab.viewController.removeFromParent()
  }
  
  func close(tab: TabItem) -> Int? {
    guard let closableTabIndex = items.firstIndex(where: {$0.isEqual(to: tab)}) else {
      return nil
    }
    let item = items.remove(at: closableTabIndex)
    closeView(for: item)
    tabBar?.reloadTabs()
    if !items.isEmpty {
      if closableTabIndex != 0 {
        tabBar?.selectItemAtIndex(closableTabIndex - 1)
      } else {
        tabBar?.selectItemAtIndex(0)
      }
    }
    return closableTabIndex
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
    select(tab: tabItem)
    if let documentTabItem = tabItem as? DocumentTabItem {
      workbench?.documentDidSelect(documentTabItem.document)
    }
  }
  
  func tabsControlWillCloseTab(_ control: TabsControl, item: AnyObject) -> Bool {
    let tabItem = (item as! TabItem)
    if let documentTabItem = tabItem as? DocumentTabItem {
      workbench?.close(document: documentTabItem.document)
    } else {
      close(tab: tabItem)
      return true
    }
    return false
  }
  
  func tabsControlDidCloseTab(_ control: TabsControl, items: [AnyObject]) {
    self.items = items.map{$0 as! TabItem}
  }
}

extension TabbedEditorController: DocumentObserver {
  func documentDidChange(_ document: Document) {
    guard let documentTabItem = items.first(where: {$0.isEqual(to: DocumentTabItem(document: document))}) as? DocumentTabItem else {
      return
    }
    documentTabItem.isChange = true
    tabBar?.reloadTabs()
    workbench?.documentDidChange(document)
  }
  
  func documentDidSave(_ document: Document) {
    guard let documentTabItem = items.first(where: {$0.isEqual(to: DocumentTabItem(document: document))}) as? DocumentTabItem else {
      return
    }
    documentTabItem.isChange = false
    tabBar?.reloadTabs()
  }
}


fileprivate struct PreviewTheme: Theme {
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
