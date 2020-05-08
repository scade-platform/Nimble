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
  lazy var toolbarItems: [NSToolbarItem] = {
    var items: [NSToolbarItem] = []

    items.append(contentsOf: CommandManager.shared.commands.filter({$0.group == nil}).map{$0.createToolbarItem()})
    items.append(contentsOf: CommandManager.shared.groups.map{$0.createToolbarItem()})

    return items
   }()

  public var observers = ObserverSet<WorkbenchObserver>()

  public private(set) var diagnostics: [Path: [Diagnostic]] = [:]
  public private(set) var tasksDictionary: [ObjectIdentifier: (WorkbenchTask, ((WorkbenchTask) -> Void)?)] = [:]

  // Document property of the WindowController always refer to the project
  public override var document: AnyObject? {
    get { super.document }
    set {
      observers.notify { $0.workbenchWillChangeProject(self) }
      super.document = newValue
      observers.notify { $0.workbenchDidChangeProject(self) }
    }
  }
    
  var mainView : NSSplitViewController? {
     return workbenchView?.children[0] as? NSSplitViewController
  }
  
  var statusBarView: StatusBarView? {
    return workbenchView?.children[1] as? StatusBarView
  }
  
  var workbenchView: NSSplitViewController? {
    contentViewController?.children[0] as? NSSplitViewController
  }
      
  var workbenchCentralView: NSSplitViewController? {
    mainView?.children[1] as? NSSplitViewController
  }
  
  var navigatorView: NavigatorView? {
    mainView?.children[0] as? NavigatorView
  }
  
  var inspectorView: InspectorView? {
    mainView?.children[2] as? InspectorView
  }
  
  var editorView: EditorView? {
    workbenchCentralView?.children[0] as? EditorView
  }
  
  var debugView: DebugView? {
    workbenchCentralView?.children[1] as? DebugView
  }

  public override func windowDidLoad() {
    super.windowDidLoad()
   
    window?.delegate = self
    window?.contentView?.wantsLayer = true
    
    // Restore window position
    window?.setFrameUsingName("NimbleWindow")
    self.windowFrameAutosaveName = "NimbleWindow"
    
    guard let debugView = debugView else { return }
    debugView.isHidden = true
    
    guard let inspectorView = inspectorView else { return }
    inspectorView.isHidden = true
    
    DocumentManager.shared.defaultDocument = BinaryFileDocument.self

    let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MainToolbar"))
    toolbar.allowsUserCustomization = true
    toolbar.displayMode = .default
    toolbar.delegate = self

    self.window?.toolbar = toolbar

    PluginManager.shared.activate(in: self)
  }
    
  public func windowWillClose(_ notification: Notification) {
    let tasks = self.tasks
    tasks.forEach {
      $0.stop()
    }

    PluginManager.shared.deactivate(in: self)
  }

  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    if !tasks.isEmpty {
       let alert = NSAlert()
       alert.alertStyle = .warning
       alert.messageText = "Are you sure you want to close the Workbench?"
       alert.informativeText = "Closing this workbench will stop the current tasks."
       alert.addButton(withTitle: "Stop Task")
       alert.addButton(withTitle: "Cancel")
       return alert.runModal() == .alertFirstButtonReturn
     }
     return true
  }

  private lazy var editorMenuItem: NSMenuItem? = {
    let mainMenu = NSApplication.shared.mainMenu
    guard let index = mainMenu?.items.firstIndex(where: {$0.title == "Editor"}) else { return nil }
    
    mainMenu?.removeItem(at: index)
    return mainMenu?.insertItem(withTitle: "Editor", action: nil, keyEquivalent: "", at: index)
  }()
  
  func currentDocumentWillChange(_ doc: Document?) {
    editorMenuItem?.submenu = nil
    statusBarView?.editorBar = []
  }
  
  func currentDocumentDidChange(_ doc: Document?) {
    let editorMenu = doc?.editor?.editorMenu
    editorMenu?.title = "Editor"
             
    editorMenuItem?.submenu = editorMenu
    statusBarView?.editorBar = doc?.editor?.statusBarItems ?? []
      
    doc?.editor?.focus()
        
    observers.notify {
      $0.workbenchActiveDocumentDidChange(self, document: doc)
    }
  }
}


// MARK: - Workbench

extension NimbleWorkbench: Workbench {
  public var tasks: [WorkbenchTask] {
    self.tasksDictionary.map{$0.value.0}
  }
  
  public var openedConsoles: [Console] {
    guard let debugView = debugView else {
      return []
    }
    return debugView.consoleView.openedConsoles
  }
  
  public var project: Project? {
    return (document as? ProjectDocument)?.project
  }
  
  public var documents: [Document] {
    return editorView?.editor.documents ?? []
  }
  
  public var currentDocument: Document? {
    return editorView?.editor.currentDocument
  }
    
  public var navigatorArea: WorkbenchArea? {
    return navigatorView
  }
  
  public var inspectorArea: WorkbenchArea? {
    return inspectorView
  }
  
  public var debugArea: WorkbenchArea? {
     return debugView
  }
  
  public var statusBar: WorkbenchStatusBar {
    return statusBarView!
  }
  
  ///TODO: rafctoring needed, we should make editor oriented creation and manage docs outside the UI
  public func open(_ doc: Document, show: Bool, openNewEditor: Bool) {
    guard let editorView = editorView else { return }
    
    editorView.showEditor()

    var opened = false

    // If no document is opened, just create a new tab
    if documents.count == 0 {
      editorView.editor.addTab(doc)
      opened = true

    // If the current document has to be presented create
    // a new tab or reuse the existing one
    } else if show {
      // If the doc is already opened, switch to its tab
      if let index = editorView.editor.findTab(doc) {
        editorView.editor.selectTab(index)
        opened = false

      // Insert a new tab for edited or newly created documents
      // and if it's forced by the flag 'openNewEditor'
      } else if let curDoc = currentDocument,
          openNewEditor || curDoc.isDocumentEdited || curDoc.fileURL == nil  {
        
        editorView.editor.insertTab(doc, at: editorView.editor.currentIndex! + 1)
        opened = true

        // Show in the current tab
      } else {
        let curDoc = self.currentDocument

        editorView.editor.show(doc)
        opened = true

        if let curDoc = curDoc {
          observers.notify { $0.workbenchDidCloseDocument(self, document: curDoc) }
        }
      }
    
    // Just insert a tab but not switch to it
    } else if editorView.editor.findTab(doc) == nil {
      editorView.editor.insertTab(doc, at: editorView.editor.currentIndex!, select: false)
      opened = true
    }

    if opened {
      doc.editor?.didOpenDocument(doc)
      observers.notify { $0.workbenchDidOpenDocument(self, document: doc) }
    }
  }
  
  
  @discardableResult
  public func close(_ doc: Document) -> Bool {
    let shouldClose: Bool = doc.close()
    
    if shouldClose {
      editorView?.editor.removeTab(doc)
      
      if let editorView = editorView, editorView.editor.items.isEmpty {
        editorView.hideEditor()
      }
      
      observers.notify { $0.workbenchDidCloseDocument(self, document: doc) }
    }
    
    return shouldClose
  }
  
  
  public func createConsole(title: String, show: Bool, startReading: Bool = true) -> Console? {
    if show, debugView?.isHidden ?? false {
      debugView?.isHidden = false
    }
    return debugView?.consoleView.createConsole(title: title, show: show, startReading: startReading)
  }
  
  public func publish(diagnostics: [Diagnostic], for path: Path) {
    if let doc = documents.first(where: {$0.path == path}){
      doc.editor?.publish(diagnostics: diagnostics)
    }
    
    if diagnostics.isEmpty {
      self.diagnostics.removeValue(forKey: path)
    } else {
      self.diagnostics[path] = diagnostics
    }
  }

  public func publish(task: WorkbenchTask) {
    task.observers.add(observer: self)
    self.tasksDictionary[task.id] = (task, nil)
  }
  
  public func publish(task: WorkbenchTask, onComplete: @escaping (WorkbenchTask)-> Void) {
    task.observers.add(observer: self)
    tasksDictionary[task.id] = (task, onComplete)
  }
}


// MARK: - WorkbenchTaskObserver

extension NimbleWorkbench: WorkbenchTaskObserver {
  public func taskDidFinish(_ task: WorkbenchTask) {    
    task.observers.remove(observer: self)
    if let (_, onComplete) = tasksDictionary[task.id] {
      onComplete?(task)
      tasksDictionary[task.id] = nil
    }
  }
}



// MARK: - NSToolbarDelegate

extension NimbleWorkbench: NSToolbarDelegate {
  ///TODO: implement ordering functionality

//  public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
//    var items: [NSToolbarItem.Identifier] = CommandManager.shared.commands.compactMap {
//      guard $0.group == nil && $0.toolbarIcon != nil else { return nil }
//      return $0.toolbarItemIdentifier
//    }
//
//    items.append(.flexibleSpace)
//    items.append(contentsOf: CommandManager.shared.groups.map { $0.toolbarItemIdentifier })
//    return items
//  }

//  public func toolbarAllowedItems(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
//    var items: [NSToolbarItem.Identifier] = CommandManager.shared.commands.compactMap {
//      guard $0.group == nil && $0.toolbarIcon != nil else { return nil }
//      return $0.toolbarItemIdentifier
//    }
//    items.append(contentsOf: CommandManager.shared.groups.map { $0.toolbarItemIdentifier })
//
//    items.append(.flexibleSpace)
//    items.append(.space)
//    items.append(.separator)
//
//    return items
//  }


  public func toolbar(_ toolbar: NSToolbar,
                      itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                      willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    
    return toolbarItems.first{ $0.itemIdentifier == itemIdentifier }
  }

  public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      var ids: [NSToolbarItem.Identifier] = CommandManager.shared.commands.compactMap {
        guard $0.group == nil && ($0.toolbarIcon != nil || $0.toolbarViewClass != nil) else { return nil }
        return $0.toolbarItemIdentifier
      }
    
      ids.append(.flexibleSpace)
      ids.append(contentsOf: CommandManager.shared.groups.map { $0.toolbarItemIdentifier })
      return ids
  }

  public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return self.toolbarDefaultItemIdentifiers(toolbar)
  }

  public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return self.toolbarDefaultItemIdentifiers(toolbar)
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

// MARK: - NimbleWorkbenchView

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
