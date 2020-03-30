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
  
  public private(set) var diagnostics: [Path: [Diagnostic]] = [:]
  
  private var toolbar: Toolbar?
  

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
  
  public override func windowWillLoad() {
    let workbenchAreaGroup = CommandGroup(name: "WorkbenchAreaGroup")
    CommandManager.shared.registerGroup(group: workbenchAreaGroup)
    
    PluginManager.shared.load()
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
    
    toolbar = Toolbar(window!, delegate: CommandsToolbarDelegate.shared)
    PluginManager.shared.activate(in: self)
  }
    
  public func windowWillClose(_ notification: Notification) {
    PluginManager.shared.deactivate(in: self)
  }
  
  private func setupCommands() {
    
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
  

  public func open(_ doc: Document, show: Bool, openNewEditor: Bool) {
    guard let editorView = editorView else { return }
    
    editorView.showEditor()
    
    // If no document is opened, just create a new tab
    if documents.count == 0 {
      editorView.editor.addTab(doc)
    
    // If the current document has to be presented create
    // a new tab or reuse the existing one
    } else if show {
      // If the doc is already opened, switch to its tab
      if let index = editorView.editor.findTab(doc) {
        editorView.editor.selectTab(index)
        
      // Insert a new tab for edited or newly created documents
      // and if it's forced by the flag 'openNewEditor'
      } else if let curDoc = currentDocument,
          openNewEditor || curDoc.isDocumentEdited || curDoc.fileURL == nil  {
        
        editorView.editor.insertTab(doc, at: editorView.editor.currentIndex! + 1)
        
        // Show in the current tab
      } else {
        let curDoc = self.currentDocument
        editorView.editor.show(doc)
        if let curDoc = curDoc {
          observers.notify { $0.workbenchDidCloseDocument(self, document: curDoc) }
        }
      }
    
    // Just insert a tab but not switch to it
    } else if editorView.editor.findTab(doc) == nil {
      editorView.editor.insertTab(doc, at: editorView.editor.currentIndex!, select: false)
    }
    
    doc.editor?.didOpenDocument(doc)
    observers.notify { $0.workbenchDidOpenDocument(self, document: doc) }
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

protocol NimbleWorkbenchArea: WorkbenchArea where Self: NSViewController {
  var changeVisibleCommand: Command? { get }
  var toolbarIcon: NSImage? { get }
}

extension NimbleWorkbenchArea {
  public var isHidden: Bool {
    set {
      guard let parent = self.parent as? NSSplitViewController else { return }
      parent.splitViewItem(for: self)?.isCollapsed = newValue
      
      
      changeVisibleCommand?.isSelected = !newValue
      changeVisibleCommand?.title = self.commandTitle
    }
    get {
      guard let parent = self.parent as? NSSplitViewController else { return true }
      return parent.splitViewItem(for: self)?.isCollapsed ?? true
    }
  }
}

extension NimbleWorkbenchArea {

  var commandTitle: String {
    let firstWord = isHidden ? "Show" : "Hide"
    return "\(firstWord) \(self.title ?? "")"
  }
  
  func createCommand() -> Command? {
    guard let title = self.title else { return nil }
    let command = Command(name: title, menuPath: "View", toolbarIcon: self.toolbarIcon) {[weak self] command in
      guard let area = self else { return }
      area.isHidden = !area.isHidden
      command.isSelected = !area.isHidden
      command.title = area.commandTitle
    }
    command.title = self.commandTitle
    command.isSelected = !self.isHidden
    
    return command
  }
  
  func registerCommand() {
    if let group = CommandManager.shared.groups["WorkbenchAreaGroup"] {
      let command = self.changeVisibleCommand
      command?.groupName = group.name
      CommandManager.shared.registerCommand(command: command!)
      group.commands.append(command!)
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
