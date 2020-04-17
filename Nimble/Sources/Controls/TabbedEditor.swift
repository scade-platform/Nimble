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

class TabItem : СustomizableTabItem {
  let document: Document
  
  fileprivate weak var parent: TabbedEditor!
  
  lazy var tabStyle: Style? = TabStyle(self)
  
  var active: Bool = false
  
  var edited: Bool {
    return document.isDocumentEdited
  }
  
  var title: String {
    return edited ? "*\(document.title)" : document.title
  }
  
  var icon: NSImage? {
    return document.icon?.image()
  }
  
  var editor: WorkbenchEditor? {
    return document.editor
  }
  
  init(_ document: Document, parent: TabbedEditor) {
    self.document = document
    self.parent = parent
  }
}


// MARK: - Tabbed Editor

class TabbedEditor: NSViewController, NimbleWorkbenchViewController {
  
  @IBOutlet weak var tabBar: TabsControl!
  @IBOutlet weak var tabViewContainer: NSView!
  
  private lazy var style: TabControlStyle = TabControlStyle(control: tabBar)
  
  var items: [TabItem] = []
  
  var documents: [Document] {
    return items.map {$0.document}
  }
      
  private(set) var currentItem: TabItem? = nil {
    didSet {
      defer {
        workbench?.currentDocumentDidChange(currentItem?.document)
      }
      currentItem?.active = true
      guard let item = currentItem else { return }
      guard let editor = item.editor else { return }
      
      editor.view.frame = tabViewContainer.frame
      
      addChild(editor)
      tabViewContainer.addSubview(editor.view)
    }     
    willSet {
      currentItem?.active = false
      guard let editor = currentItem?.editor else { return }
      editor.view.removeFromSuperview()
      editor.removeFromParent()
      
      workbench?.currentDocumentWillChange(currentItem?.document)
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
    
    tabBar.style = style
    tabBar.delegate = self
    tabBar.dataSource = self
        
    updateVisuals()

    WorkbenchSettings.shared.$showFileIconsInTabs.observers.add(observer: self)
    WorkbenchSettings.shared.$tabCloseButtonPosition.observers.add(observer: self)

    ThemeManager.shared.observers.add(observer: self)
  }
  
  private func updateVisuals() {
    let tabBarColor = style.theme.unselectableTabButtonTheme.backgroundColor
    tabBar.setBackgroundColor(tabBarColor)
    
    tabBar.reloadTabs()
  }
  
  func show(_ doc: Document) {
    guard let index = currentIndex else { return }
    items[index] = TabItem(doc, parent: self)
    tabBar.reloadTabs()
    selectTab(index)
  }
  
  func addTab(_ doc: Document, select: Bool = true) {
    insertTab(doc, at: items.endIndex)
  }
  
  func insertTab(_ doc: Document, at pos: Int, select: Bool = true) {
    let curIndex = currentIndex
    
    let item = TabItem(doc, parent: self)
    
    item.parent = self
    doc.observers.add(observer: self)
    items.insert(item, at: pos)
    
    tabBar.reloadTabs()
        
    if select {
      selectTab(pos)      
    } else if let curIndex = curIndex, curIndex >= pos {
      selectTab(curIndex + 1)
    }
  }
  
  func removeTab(_ doc: Document) {
    guard let pos = items.firstIndex(where: {$0.document === doc}) else { return }
        
    items[pos].parent = nil
    doc.observers.remove(observer: self)
    items.remove(at: pos)
    
    tabBar.reloadTabs()
    
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
    tabBar.selectItemAtIndex(index)
  }
  
  func findTab(_ doc: Document) -> Int? {
    let docType = type(of: doc)

    return items.firstIndex {
      if type(of: $0.document) == docType {
        guard let p1 = $0.document.path, let p2 = doc.path else { return false }

        return p1 == p2
      }
      return false
    }
  }
}


// MARK: - Observers

extension TabbedEditor: ThemeObserver {
  func themeDidChanged(_ theme: NimbleCore.Theme) {
    self.updateVisuals()
  }
}

extension TabbedEditor: SettingObserver {
  func settingValueDidChange<T: Codable>(_ setting: Setting<T>) {
    self.updateVisuals()
  }
}

extension TabbedEditor: DocumentObserver {
  func documentDidChange(_ document: Document) {
    tabBar.reloadTabs()
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
  
  func tabsControl(_ control: TabsControl, iconForItem item:AnyObject) -> NSImage? {
    return WorkbenchSettings.shared.showFileIconsInTabs ? (item as! TabItem).icon : nil
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
    guard let item = item as? TabItem else { return }
    if let curItem = currentItem, curItem === item {
      return //item.document.activate()
    }
    currentItem = item
  }
  
  func tabsControlWillCloseTab(_ control: TabsControl, item: AnyObject) -> Bool {
    let item = item as! TabItem
    return workbench?.close(item.document) ?? true
  }
}

// MARK: - Theme & Style

fileprivate struct TabControlStyle: ThemedStyle {
  weak var control: TabsControl!

  let theme: KPCTabsControl.Theme = TabTheme()
  let tabButtonWidth: TabWidth = .flexible(min: 70, max: 250)
  let tabsControlRecommendedHeight: CGFloat = 24.0 // No impact for now
}

fileprivate struct TabStyle: ThemedStyle {
  private weak var item: TabItem!
  
  public let theme: KPCTabsControl.Theme = TabTheme()
  
  let tabButtonWidth: TabWidth = .flexible(min: 70, max: 250)
  let tabsControlRecommendedHeight: CGFloat = 24.0 // No impact for now
  var tabButtonCloseButtonPosition: CloseButtonPosition {
    WorkbenchSettings.shared.tabCloseButtonPosition
  }

  init(_ item: TabItem) {
    self.item = item
  }

  func tabButtonBorderMask(_ button: TabButtonCell) -> BorderMask? {
    return button.dragging ? [.left, .right] : .right
  }
}


fileprivate struct TabTheme: KPCTabsControl.Theme {
  
  public init() { }
  
  public let tabsControlTheme: TabsControlTheme = DefaultTabsControlTheme()

  public let tabButtonTheme: TabButtonTheme = DefaultTabButtonTheme()
  public let selectedTabButtonTheme: TabButtonTheme = SelectedTabButtonTheme()
  public let unselectableTabButtonTheme: TabButtonTheme = DefaultTabButtonTheme()
      
  private static var sharedBorderColor: NSColor {
    switch Theme.Style.system {
    case .dark:
      return NSColor(colorCode: "#303030")!
    case .light:
      return NSColor(colorCode: "#B1B1B1")!
    }
  }
  
  fileprivate static var sharedBackgroundColor: NSColor {
    switch Theme.Style.system {
    case .dark:
      return .controlBackgroundColor
    case .light:
      return NSColor(colorCode: "#CACACA")!
    }
  }
  
  private static var sharedTitleFont: NSFont { NSFont.systemFont(ofSize: 12) }
  private static var sharedTitleColor: NSColor {
    if sharedBackgroundColor.isDark {
      return NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    } else {
      return NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
  }
  
  // Themes
    
  fileprivate struct DefaultTabButtonTheme: KPCTabsControl.TabButtonTheme {
    var backgroundColor: NSColor { TabTheme.sharedBackgroundColor }
    var borderColor: NSColor { TabTheme.sharedBorderColor }
    var titleColor: NSColor {
      if TabTheme.sharedBackgroundColor.isDark {
        return TabTheme.sharedTitleColor.darkerColor(by: 0.3)
      } else {
        return TabTheme.sharedTitleColor.lighterColor(by: 0.3)
      }
    }
    var titleFont: NSFont { TabTheme.sharedTitleFont }
  }
  
  fileprivate struct SelectedTabButtonTheme: KPCTabsControl.TabButtonTheme {
    var backgroundColor: NSColor {
      switch Theme.Style.system {
      case .dark:
        return NSColor(colorCode: "#2C2C2D")! //NSColor.underPageBackgroundColor
      case .light:
        return .controlBackgroundColor
      }
    }
    
    var borderColor: NSColor { TabTheme.sharedBorderColor }
    var titleColor: NSColor { TabTheme.sharedTitleColor }
    var titleFont: NSFont { TabTheme.sharedTitleFont }
  }
  
  fileprivate struct DefaultTabsControlTheme: KPCTabsControl.TabsControlTheme {
    var backgroundColor: NSColor { return TabTheme.sharedBackgroundColor }
    var borderColor: NSColor { return TabTheme.sharedBorderColor }
  }
}
