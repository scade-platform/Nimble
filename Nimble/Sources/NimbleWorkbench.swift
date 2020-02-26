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
  
  @IBOutlet weak var toolbar: NSToolbar!
  
  public private(set) var diagnostics: [Path: [Diagnostic]] = [:]
  
  private lazy var toolbarItems: [NSToolbarItem.Identifier] = {
    if CommandManager.shared.commands.isEmpty {
      // Force plugins loading
       _ = PluginManager.shared
    }
    let toolbarCommands = CommandManager.shared.commands
      .filter{$0.toolbarIcon != nil}
    toolbarCommands.forEach{$0.observers.add(observer: self)}
    return toolbarCommands.map{NSToolbarItem.Identifier($0.name)}
  }()
  
  
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
  
  var editorView: TabbedEditor? {
    workbenchCentralView?.children[0] as? TabbedEditor
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
    
    DocumentManager.shared.defaultDocument = BinaryFileDocument.self
    
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

extension NimbleWorkbench : NSToolbarDelegate {
  public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    var result = toolbarItems
    result.append(.flexibleSpace)
    result.append(.space)
    return result
  }
  
  public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return toolbarItems
  }
  
  public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    let commands = CommandManager.shared.commands
    for command in commands {
      if command.name == itemIdentifier.rawValue {
        return toolbarPushButton(identifier: itemIdentifier, for: command)
      }
    }
    return nil
  }
  
  private func toolbarPushButton(identifier: NSToolbarItem.Identifier, for command: Command) -> NSToolbarItem {
    let item = NSToolbarItem(itemIdentifier: identifier)
    item.label = command.name
    item.paletteLabel = command.name
    let button = NSButton()
    button.cell = ButtonCell()
    button.image = command.toolbarIcon
    button.action = #selector(command.execute)
    button.target = command
    let width: CGFloat = 38.0
    let height: CGFloat = 28.0
    button.widthAnchor.constraint(equalToConstant: width).isActive = true
    button.heightAnchor.constraint(equalToConstant: height).isActive = true
    button.title = ""
    button.imageScaling = .scaleProportionallyDown
    button.bezelStyle = .texturedRounded
    button.focusRingType = .none
    item.view = button
    item.isEnabled = command.isEnable
    return item
  }
}


extension NimbleWorkbench : CommandObserver {
  public func commandDidChange(_ command: Command) {
    for item in toolbar.items {
      guard item.itemIdentifier.rawValue == command.name else { continue }
      DispatchQueue.main.async {
        item.isEnabled = command.isEnable
      }
      return
    }
  }
  
  
}

// MARK: - Workbench

extension NimbleWorkbench: Workbench {
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
    return statusBarView!
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
  
  
  public func createConsole(title: String, show: Bool, startReading: Bool = true) -> Console? {
    if show, debugView?.isHidden ?? false {
      debugView?.isHidden = false
    }
    return debugView?.consoleView.createConsole(title: title, show: show, startReading: startReading)
  }
  
  public func publishDiagnostics(for path: Path, diagnostics: [Diagnostic]) {
    if let doc = documents.first(where: {$0.path == path}){
      doc.editor?.publish(diagnostics: diagnostics)
    }
    
    if diagnostics.isEmpty {
      self.diagnostics.removeValue(forKey: path)
    } else {
      self.diagnostics[path] = diagnostics
    }
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


fileprivate class ButtonCell: NSButtonCell {
  
  override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
    super.drawImage(image, withFrame: frame.insetBy(dx: 0, dy: 2), in: controlView)
  }
  
}
