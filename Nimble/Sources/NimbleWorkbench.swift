//
//  NimbleWorkbench.swift
//  Nimble
//
//  Created by Grigory Markin on 01.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


// MARK: - NimbleWorkbench

public class NimbleWorkbench: NSWindowController, NSWindowDelegate {
  public var observers = ObserverSet<WorkbenchObserver>()
  
  // Document property of the WindowController always refer to the project
  public override var document: AnyObject? {
    get { super.document }
    set {
      observers.notify { $0.workbenchWillChangeProject(self) }
      super.document = newValue
      observers.notify { $0.workbenchDidChangeProject(self) }
    }
  }
  
  var statusBarView: StatusBarView? {
    return workbenchView?.children[1] as? StatusBarView
  }
  
  var mainView : NSSplitViewController? {
     return workbenchView?.children[0] as? NSSplitViewController
  }
  
  var workbenchView: NSSplitViewController? {
    contentViewController as? NSSplitViewController
  }
      
  var workbenchCentralView: NSSplitViewController? {
    mainView?.children[1] as? NSSplitViewController
  }
  
  var navigatorView: NavigatorView? {
    mainView?.children[0] as? NavigatorView
  }
  
  var editorView: TabbedEditor? {
    workbenchCentralView?.children[0] as? TabbedEditor
  }
  
  var debugView: DebugView? {
    workbenchCentralView?.children[1] as? DebugView
  }
  
  public override func windowDidLoad() {
    super.windowDidLoad()
    window?.delegate = self
    
    // Restore window position
    window?.setFrameUsingName("NimbleWindow")
    self.windowFrameAutosaveName = "NimbleWindow"
    
    guard let debugView = debugView else { return }
    debugView.isHidden = true
    
    DocumentManager.shared.registerDocumentClass(BinaryFileDocument.self, isDefault: true)
    
    PluginManager.shared.activate(in: self)
  }
    
  public func windowWillClose(_ notification: Notification) {
    PluginManager.shared.deactivate(in: self)
  }
  
  private lazy var editorMenuItem: NSMenuItem? = {
    let mainMenu = NSApplication.shared.mainMenu
    guard let index = mainMenu?.items.firstIndex(where: {$0.title == "Editor"}) else { return nil }
    
    mainMenu?.removeItem(at: index)
    return mainMenu?.insertItem(withTitle: "Editor", action: nil, keyEquivalent: "", at: index)
  }()
  
  func currentDocumentDidChange(_ document: Document?) {
    let editorMenu = document?.editor?.editorMenu
    editorMenu?.title = "Editor"
    
    editorMenuItem?.submenu = editorMenu

    document?.editor?.focus()
    
    observers.notify {
      $0.workbenchActiveDocumentDidChange(self, document: document)
    }
  }
}


// MARK: - Workbench

extension NimbleWorkbench: Workbench {
  public var project: Project? {
    return (document as? ProjectDocument)?.project
  }
  
  public var documents: [Document] {
    return editorView?.documents ?? []
  }
  
  public var currentDocument: Document? {
    return editorView?.currentDocument
  }
    
  public var navigatorArea: WorkbenchArea? {
    return navigatorView
  }
  
  public var debugArea: WorkbenchArea? {
     return debugView
  }
  
  public var statusBar: WorkbenchStatusBar {
    return statusBarView as! WorkbenchStatusBar
  }
  

  public func open(_ doc: Document, show: Bool, openNewEditor: Bool) {
    guard let editorView = editorView else { return }
    
    // If no document is opened, just create a new tab
    if documents.count == 0 {
      editorView.addTab(doc)
    
    // If the current document has to be presented create
    // a new tab or reuse the existing one
    } else if show {
      // If the doc is already opened, switch to its tab
      if let index = editorView.findTab(doc) {
        editorView.selectTab(index)
        
      // Insert a new tab for edited or newly created documents
      // and if it's forced by the flag 'openNewEditor'
      } else if let curDoc = currentDocument,
          openNewEditor || curDoc.isDocumentEdited || curDoc.fileURL == nil  {
        
        editorView.insertTab(doc, at: editorView.currentIndex! + 1)
        
        // Show in the current tab
      } else {
        let curDoc = self.currentDocument
        editorView.show(doc)
        if let curDoc = curDoc {
          observers.notify { $0.workbenchDidCloseDocument(self, document: curDoc) }
        }
      }
    
    // Just insert a tab but not switch to it
    } else if editorView.findTab(doc) == nil {
      editorView.insertTab(doc, at: editorView.currentIndex!, select: false)
    }
    
    observers.notify { $0.workbenchDidOpenDocument(self, document: doc) }
  }
  
  
  @discardableResult
  public func close(_ doc: Document) -> Bool {
    let shouldClose: Bool = doc.close()
    
    if shouldClose {
      editorView?.removeTab(doc)
      observers.notify { $0.workbenchDidCloseDocument(self, document: doc) }
    }
    
    return shouldClose
  }
  
  
  public func createConsole(title: String, show: Bool) -> Console? {
    if show, debugView?.isHidden ?? false {
      debugView?.isHidden = false
    }
    return debugView?.consoleView.createConsole(title: title, show: show)
  }
}


// MARK: - Actions

extension NimbleWorkbench {
  @IBAction func save(_ sender: Any?) {
    currentDocument?.save(sender)
  }
  
  @IBAction func saveAs(_ sender: Any?) {    
    currentDocument?.saveAs(sender)
  }
  
  @IBAction func saveAll(_ sender: Any?) {
    documents.forEach{$0.save(sender)}
  }
  
  @IBAction func close(_ sender: Any?) {
    guard let doc = currentDocument else { return }
    close(doc)
  }
  
  @IBAction func closeAll(_ sender: Any?) {
    documents.forEach{close($0)}
  }
  
  @IBAction func addFolder(_ sender: Any?) {
    let openPanel = NSOpenPanel();
    openPanel.selectFolders()
      .compactMap{Folder(url: $0)}
      .forEach{ self.project?.add($0) }
  }
  
  @objc func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let menuId = (item as? NSMenuItem)?.identifier?.rawValue else { return true }
    switch menuId {
    case "saveMenuItem", "saveAsMenuItem":
      return currentDocument != nil
    case "saveAllMenuItem":
      return documents.contains{$0.isDocumentEdited}
    case "closeMenuItem", "closeAllMenuItem":
      return !documents.isEmpty
    default:
      return true
    }
  }
}


// MARK: - NimbleWorkbenchArea

protocol NimbleWorkbenchArea: WorkbenchArea where Self: NSViewController { }
extension NimbleWorkbenchArea {
  public var isHidden: Bool {
    set {
      guard let parent = self.parent as? NSSplitViewController else { return }
      parent.splitViewItem(for: self)?.isCollapsed = newValue
    }
    get {
      guard let parent = self.parent as? NSSplitViewController else { return true }
      return parent.splitViewItem(for: self)?.isCollapsed ?? true
    }
  }
}



// MARK: - NimbleWorkbenchWiew

protocol NimbleWorkbenchView { }
protocol NimbleWorkbenchViewController {}


extension NimbleWorkbenchView where Self: NSView {
  var workbench: NimbleWorkbench? {
    return window?.windowController as? NimbleWorkbench
  }
}

extension NimbleWorkbenchViewController where Self: NSViewController {
  var workbench: NimbleWorkbench? {
    return view.window?.windowController as? NimbleWorkbench
  }
}
