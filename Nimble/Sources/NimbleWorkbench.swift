//
//  NimbleWorkbench.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Cocoa
import NimbleCore


// MARK: - NimbleWorkbench

public class NimbleWorkbench: NSWindowController, NSWindowDelegate {
  
  lazy var toolbarItems: [NSToolbarItem] = {
    // Filter out groups that do not group inside the toolbar

    var items = CommandManager.shared.commands
      .filter{
        guard let group = $0.group else { return true }
        return !group.toolbarGroup
      }.map{
        $0.createToolbarItem(for: self)
      }

    let groupItems = CommandManager.shared.groups
      .filter{$0.toolbarGroup}
      .map{$0.createToolbarItem()}

    items.append(contentsOf: groupItems)
    return items
   }()

  public var observers = ObserverSet<WorkbenchObserver>()

  public private(set) var diagnostics: [DiagnosticSource: [Diagnostic]] = [:]

  public private(set) var tasksDictionary: [ObjectIdentifier: (WorkbenchTask, ((WorkbenchTask) -> Void)?)] = [:]

  let navigatorPanelSeparatorIdentifier = NSToolbarItem.Identifier(rawValue: "NavigatorPanel")
  let inspectorPanelSeparatorIdentifier = NSToolbarItem.Identifier(rawValue: "InspectorPanel")

  // Document property of the WindowController always refer to the project
  public override var document: AnyObject? {
    get { super.document }
    set {
      observers.notify { $0.workbenchWillChangeProject(self) }
      super.document = newValue
      self.project?.workbench = self
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
  
  var settingsController: SettingsController? {
    (self.contentViewController as? WorkbenchContentViewController)?.settingsController
  }
    
  private var lastDebugViewPosition: CGFloat = 0
  private let collapsedDebugViewHeight: CGFloat = 30
  private var isDebugViewCollapsed: Bool {
    get {
      return currentDebugViewHeight < collapsedDebugViewHeight
    }
  }
  private var currentDebugViewHeight: CGFloat {
    get {
      return workbenchCentralView?.splitViewItems.last?.viewController.view.frame.height ?? 0
    }
  }
  
  private func openDebugView() {
    guard isDebugViewCollapsed else { return }
    controlBottomStackVisibilityOfConsole()
    changePositionOfDebugView(position: lastDebugViewPosition)
  }

  private var tabbedEditorViewModel: TabbedEditorViewModel!

  public override func windowDidLoad() {
    super.windowDidLoad()
   
    window?.delegate = self
    window?.contentView?.wantsLayer = true
    
    // Restore window position
    window?.setFrameUsingName("NimbleWindow")
    self.windowFrameAutosaveName = "NimbleWindow"
    
    
    let position = workbenchCentralView?.splitView.frame.maxY ?? 0
    lastDebugViewPosition = position / 2
    workbenchCentralView?.splitView.setPosition(position, ofDividerAt: 0)

    guard let debugView = debugView else { return }
    debugView.isHidden = false
      debugView.collapseCallback = { [weak self] in
          self?.collapseDebugView()
      }
      
      debugView.openCallback = { [weak self] in
          self?.openDebugView()
      }
      
    guard let inspectorView = inspectorView else { return }
    inspectorView.isHidden = true

    guard let editorView = editorView else { return }
    tabbedEditorViewModel = TabbedEditorViewModel(responder: self)
    editorView.tabbedEditorViewModel = tabbedEditorViewModel
    DocumentManager.shared.defaultDocument = BinaryFileDocument.self

    let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MainToolbar"))
    toolbar.allowsUserCustomization = true
    toolbar.displayMode = .default
    toolbar.showsBaselineSeparator = false
    toolbar.delegate = self

    self.window?.toolbar = toolbar
    self.window?.isMovableByWindowBackground = false

    PluginManager.shared.activate(in: self)
  }
    
  private func collapseDebugView() {
    guard let splitViewFrame = workbenchCentralView?.splitView.frame else { return }
    if (lastDebugViewPosition == 0 || currentDebugViewHeight != lastDebugViewPosition) && currentDebugViewHeight > collapsedDebugViewHeight {
      lastDebugViewPosition = splitViewFrame.height - currentDebugViewHeight
    }
    let updatedPosition: CGFloat = currentDebugViewHeight > collapsedDebugViewHeight ? splitViewFrame.maxY : lastDebugViewPosition
    
    controlBottomStackVisibilityOfConsole()
    
    changePositionOfDebugView(position: updatedPosition)
  }
    
  private func changePositionOfDebugView(position: CGFloat) {
    let duration: TimeInterval = 0.25
    NSAnimationContext.runAnimationGroup { context in
      context.duration = duration
      context.allowsImplicitAnimation = true
      workbenchCentralView?.splitView.setPosition(position, ofDividerAt: 0)
      workbenchCentralView?.splitView.layoutSubtreeIfNeeded()
    }
  }
  
  private func controlBottomStackVisibilityOfConsole() {
    debugView?.consoleView?.bottomStackView.isHidden = currentDebugViewHeight > collapsedDebugViewHeight
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
  
  public override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    let values = documents
      .filter { $0.fileURL != nil}
      .map { DocumentSessionState(doc: $0) }

    coder.encode(values, forKey: "openDocuments")
    PluginManager.shared.encodeRestorableState(in: self, coder: coder)
  }
  
  public override func restoreState(with coder: NSCoder) {
    super.restoreState(with: coder)

    if let stateValues = coder.decodeObject(forKey: "openDocuments") as? [DocumentSessionState] {
      let docManager = DocumentManager.shared
      for state in stateValues {
        guard let url = state.url,
              let path = Path(url: url),
              path.exists && path.isReadable,
              let docType = docManager.findDocumentType(by: state.type),
              let doc = docManager.open(path: path, docType: docType) else { continue }
        
        if let settingsPath = Settings.defaultPath, settingsPath == path {
          settingsController?.openSettingsEditor(in: self)
        } else {
          self.open(doc, show: true, openNewEditor: true)
        }
      }
    }
    
    PluginManager.shared.restoreState(in: self, coder: coder)
  }
  
  public override func invalidateRestorableState() {
    super.invalidateRestorableState()
    (document as? ProjectDocument)?.invalidateRestorableState()
  }
  
  private lazy var editorMenuItem: NSMenuItem? = {
    let mainMenu = NSApplication.shared.mainMenu
    return mainMenu?.items.first(where: {$0.title == "Editor"})
  }()

}


// MARK: - Workbench

extension NimbleWorkbench: Workbench {
  public var tasks: [WorkbenchTask] {
    self.tasksDictionary.map{$0.value.0}
  }
  
  public var openedConsoles: [Console] {
    return debugView?.consoleView?.openedConsoles ?? []
  }
  
  public var project: Project? {
    return (document as? ProjectDocument)?.project
  }
  
  public var documents: [Document] {
    tabbedEditorViewModel.documents
  }
  
  public var currentDocument: Document? {
    tabbedEditorViewModel.currentDocument
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

    // Show doc in tabbed editor
    tabbedEditorViewModel.open(doc, show: show, openNewEditor: openNewEditor)
  }
  
  @discardableResult
  public func close(_ doc: Document) -> Bool {
    tabbedEditorViewModel.close(doc)
  }
  
  
  public func createConsole(title: String, show: Bool, startReading: Bool = true) -> Console? {
    return debugView?.consoleView?.createConsole(title: title, show: show, startReading: startReading)
  }
  
  public func publish(diagnostics: [Diagnostic], for source: DiagnosticSource) {
    if case .path(let path) = source, let doc = documents.first(where: {$0.path == path}) {
      doc.editor?.publish(diagnostics: diagnostics)
    }

    if diagnostics.isEmpty {
      self.diagnostics.removeValue(forKey: source)
    } else {
      self.diagnostics[source] = diagnostics
    }
      
    observers.notify{ $0.workbenchDidPublishDiagnostic(self, diagnostic: self.diagnostics[source] ?? diagnostics, source: source) }
  }

  public func publish(task: WorkbenchTask) {
    task.observers.add(observer: self)
    self.tasksDictionary[task.id] = (task, nil)
  }
  
  public func publish(task: WorkbenchTask, onComplete: @escaping (WorkbenchTask)-> Void) {
    task.observers.add(observer: self)
    tasksDictionary[task.id] = (task, onComplete)
  }

  public func openSettings() {
    settingsController?.openSettingsEditor(in: self)
  }
}

// MARK: - TabbedEditorResponder

extension NimbleWorkbench: TabbedEditorResponder {
  func documentDidOpen(_ document: Document) {
    observers.notify { $0.workbenchDidOpenDocument(self, document: document) }
  }

  func documentDidClose(_ document: Document) {
    if documents.isEmpty {
      editorView?.hideEditor()
    }
    observers.notify { $0.workbenchDidCloseDocument(self, document: document) }
  }

  func currentDocumentWillChange(_ document: Document?) {
    editorMenuItem?.submenu = nil
    debugView?.editorBar = []
  }

  func currentDocumentDidChange(_ document: Document?) {
    if let editor = document?.editor {

      (self.document as? ProjectDocument)?.undoManager = document?.undoManager

      let editorMenu = type(of: editor).editorMenu

      editorMenu?.title = "Editor"

      if editorMenuItem?.submenu != editorMenu {
        editorMenuItem?.submenu = editorMenu
        editorMenuItem?.isEnabled = true
      }

      debugView?.editorBar = editor.statusBarItems
      editor.focus()
    }

    observers.notify {
      $0.workbenchActiveDocumentDidChange(self, document: document)
    }
  }

  func documentUpdates() {
    observers.notify {
      $0.workbenchDidUpdateDocuments(self)
    }
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

  func updateToolBar() {
    guard let toolbar = window?.toolbar else {
      return
    }
    toolbar.items.forEach { _ in toolbar.removeItem(at: 0) }
    let items = toolbarDefaultItemIdentifiers(toolbar).reversed()
    for item in items {
      toolbar.insertItem(withItemIdentifier: item, at: 0)
    }
  }

  public func toolbar(_ toolbar: NSToolbar,
                      itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                      willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    if let mainView {
      if itemIdentifier == navigatorPanelSeparatorIdentifier {
        if !(navigatorArea?.isHidden ?? true) {
          return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier, splitView: mainView.splitView, dividerIndex: 0)
        }
      } else if itemIdentifier == inspectorPanelSeparatorIdentifier {
        if !(inspectorArea?.isHidden ?? true) {
          return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier, splitView: mainView.splitView, dividerIndex: 1)
        }
      }
    }
    return toolbarItems.first{ $0.itemIdentifier == itemIdentifier }
  }

  public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    let commands = CommandManager.shared.commands.filter {
      guard $0.toolbarIcon != nil || $0.toolbarControlClass != nil else { return false }
      guard let group = $0.group else { return true }
      return !group.toolbarGroup
    }

    let groups = CommandManager.shared.groups.filter {
      return $0.toolbarGroup
    }


    let (leftCommands, leftGroups) = filterCommandAndGroup(for: .left, commands: commands, groups: groups)
    let sortedLeftGroup = createAlignGroupItems(commands: leftCommands, groups: leftGroups, insertSpaces: !(navigatorArea?.isHidden ?? true))

    let (centerCommands, centerGroups) = filterCommandAndGroup(for: .center, commands: commands, groups: groups)
    let sortedCenterGroup = createAlignGroupItems(commands: centerCommands, groups: centerGroups)

    let (rightCommands, rightGroups) = filterCommandAndGroup(for: .right, commands: commands, groups: groups)
    let sortedRightGroup = createAlignGroupItems(commands: rightCommands, groups: rightGroups, insertSpaces: !(inspectorArea?.isHidden ?? true))

    // Result
    var ids: [NSToolbarItem.Identifier] = sortedLeftGroup
    ids.append(navigatorPanelSeparatorIdentifier)
    ids.append(contentsOf: sortedCenterGroup)
    ids.append(inspectorPanelSeparatorIdentifier)
    ids.append(contentsOf: sortedRightGroup)
    return ids
  }

  private func filterCommandAndGroup(for alignment: ToolbarAlignment.Case, commands: [Command], groups: [CommandGroup]) -> ([Command], [CommandGroup]) {
    let resultCommands: [Command] = commands.filter { command in
      if let alignGroup = command.alignmentGroup {
        return alignGroup.is(alignment)
      } else {
        return command.alignment.is(alignment)
      }
    }

    let resultGrops: [CommandGroup] = groups.filter { group in
      if let alignGroup = group.alignmentGroup {
        return alignGroup.is(alignment)
      } else {
        return group.alignment.is(alignment)
      }
    }
    return (resultCommands, resultGrops)
  }

  private func createAlignGroupItems(commands: [Command], groups: [CommandGroup], insertSpaces: Bool = true) -> [NSToolbarItem.Identifier] {
    var leftGroup: [Any] = commands.filter{$0.alignment.is(.left)}
    leftGroup.append(contentsOf: groups.filter{ $0.alignment.is(.left)})
    let sortedLeftGroup = leftGroup.sorted{l, r in sortedPredicate(l, r, {$0 < $1})}

    // Center group
    var centerGroup: [Any] = commands.filter{$0.alignment.is(.center)}
    centerGroup.append(contentsOf: groups.filter{ $0.alignment.is(.center)})
    let sortedCenterGroup = centerGroup.sorted{l, r in sortedPredicate(l, r, {$0 < $1})}

    // Right group
    var rightGroup: [Any] = commands.filter{$0.alignment.is(.right)}
    rightGroup.append(contentsOf: groups.filter{ $0.alignment.is(.right)})
    let sortedRightGroup = rightGroup.sorted{l, r in sortedPredicate(l, r, {$0 > $1})}

    var ids: [NSToolbarItem.Identifier] = sortedLeftGroup.compactMap(extractIdentifier(_:))

    if insertSpaces {
      ids.append(.flexibleSpace)
    }

    ids.append(contentsOf: sortedCenterGroup.compactMap(extractIdentifier(_:)))

    if insertSpaces {
      ids.append(.flexibleSpace)
    }

    ids.append(contentsOf: sortedRightGroup.compactMap(extractIdentifier(_:)))

    return ids
  }

  public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    let set: Set<NSToolbarItem.Identifier> = Set(self.toolbarDefaultItemIdentifiers(toolbar))
    return Array(set)
  }

  public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return [] //self.toolbarDefaultItemIdentifiers(toolbar)
  }
  
  private func sortedPredicate(_ l: Any, _ r: Any, _ predicate: (Int, Int) -> Bool) -> Bool {
    let leftPriority: Int
    let rightPriority: Int
    
    if let command = l as? Command {
      switch command.alignment {
      case .left(let orderPriority), .center(let orderPriority), .right(let orderPriority):
        leftPriority = orderPriority
      }
    } else if let group = l as? CommandGroup {
      switch group.alignment {
      case .left(let orderPriority), .center(let orderPriority), .right(let orderPriority):
        leftPriority = orderPriority
      }
    } else {
      leftPriority = Int.max
    }
    
    if let command = r as? Command {
      switch command.alignment {
      case .left(let orderPriority), .center(let orderPriority), .right(let orderPriority):
        rightPriority = orderPriority
      }
    } else if let group = r as? CommandGroup {
      switch group.alignment {
      case .left(let orderPriority), .center(let orderPriority), .right(let orderPriority):
        rightPriority = orderPriority
      }
    } else {
      rightPriority = Int.max
    }
    
    return predicate(leftPriority, rightPriority)
  }
  
  func extractIdentifier(_ element: Any) -> NSToolbarItem.Identifier? {
    if let command = element as? Command {
      return command.toolbarItemIdentifier
    } else if let group = element as? CommandGroup {
      return group.toolbarItemIdentifier
    } else {
      return nil
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
    invalidateRestorableState()
  }

  @IBAction func copy(_ sender: Any?) {
    guard let doc = currentDocument as? EditableDocument else { return }
    doc.onCopy()
  }

  @IBAction func paste(_ sender: Any?) {
    guard let doc = currentDocument as? EditableDocument else { return }
    doc.onPaste()
  }
  
  @IBAction func closeAll(_ sender: Any?) {
    documents.forEach{close($0)}
    invalidateRestorableState()
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


// MARK: - WorkbenchView

protocol WorkbenchView { }
protocol WorkbenchViewController {}


extension WorkbenchView where Self: NSView {
  var workbench: Workbench? {
    return window?.windowController as? NimbleWorkbench
  }
}

extension WorkbenchViewController where Self: NSViewController {
  var workbench: Workbench? {
    return view.window?.windowController as? NimbleWorkbench
  }
}

