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
    let title: String
    let selectable: Bool
    let viewController: NSViewController
    init(title: String, viewController: NSViewController, selectable: Bool = true) {
        self.title = title
        self.selectable = selectable
        self.viewController = viewController
    }
}

extension TabItem: Equatable {
    static func ==(lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.title == rhs.title
    }
}

class TabbedEditorController : NSViewController {
    
    @IBOutlet weak var tabBar: TabsControl?
    @IBOutlet weak var tabViewContainer: NSView!
    
    private var items = [TabItem]()
    private var currentItem: TabItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar?.style = NimbleStyle()
        tabBar?.dataSource = self
        tabBar?.delegate = self
        tabBar?.reloadTabs()
    }
    
    func addNewTab(viewController tabView: NSViewController, file: File){
        let newTabItem = TabItem(title: file.name, viewController: tabView)
        items.append(newTabItem)
        selectTabItem(tabItem: newTabItem)
        tabBar?.reloadTabs()
        tabBar?.selectItemAtIndex(items.count - 1)
    }
    
    private func selectTabItem(tabItem: TabItem){
        if let currentItem = self.currentItem {
            closeTabItem(tabItem: currentItem)
        }
        currentItem = tabItem
        tabItem.viewController.view.frame = tabViewContainer.frame
        addChild(tabItem.viewController)
        tabViewContainer.addSubview(tabItem.viewController.view)
        currentItem = tabItem
    }
    
    private func closeTabItem(tabItem: TabItem) {
        tabItem.viewController.view.removeFromSuperview()
        tabItem.viewController.removeFromParent()
    }
    
}

extension TabbedEditorController : TabsControlDataSource {
    
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

extension TabbedEditorController : TabsControlDelegate {
    
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
        selectTabItem(tabItem: tabItem)
    }
    
    func tabsControlWillCloseTab(_ control: TabsControl, item: AnyObject) {
        let tabItem = (item as! TabItem)
        closeTabItem(tabItem: tabItem)
    }
    
    func tabsControlDidCloseTab(_ control: TabsControl, items: [AnyObject]) {
        self.items = items.map{$0 as! TabItem}
    }
}







