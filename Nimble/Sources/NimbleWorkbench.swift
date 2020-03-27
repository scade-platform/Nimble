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
  
  private var toolbarGroups: [NSObjectGroupWrapper] = []
  
  private lazy var toolbarItems: [NSToolbarItem.Identifier] = {
    guard !CommandManager.shared.commands.isEmpty else {
      return []
    }
    
    let toolbarCommands = CommandManager.shared.commands
      .filter{$0.toolbarIcon != nil}
      .filter{$0.groupName == nil}
    var result = toolbarCommands.map{NSToolbarItem.Identifier($0.name)}
    result.append(.flexibleSpace)
    result.append(contentsOf: CommandManager.shared.groups.values.map{NSToolbarItem.Identifier($0.name)})
    return result
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
    PluginManager.shared.load()
    
    toolbar.delegate = self
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
    
    setupCommands()
    PluginManager.shared.activate(in: self)
  }
    
  public func windowWillClose(_ notification: Notification) {
    PluginManager.shared.deactivate(in: self)
    toolbarGroups.removeAll()
  }
  
  private func setupCommands() {
    let workbenchAreaGroup = CommandGroup(name: "WorkbenchAreaGroup")
    let color = NSColor(named: "ButtonIconColor", bundle: Bundle.main) ?? .darkGray
    
    //Command to show/hide Navigator Area
    let leftSideBarIcon = Bundle.main.image(forResource: "leftSideBar")?.imageWithTint(color)
    
    let changeNavigatorAreaVisabilityCommand = Command(name: "ChangeNavigatorAreaVisabilityCommand", menuPath: "View", toolbarIcon: leftSideBarIcon) { [weak self] command in
      guard let navigatorArea = self?.navigatorArea else { return }
      let title = navigatorArea.isHidden  ? "Hide Navigator Area" : "Show Navigator Area"
      command.title = title
      navigatorArea.isHidden = !navigatorArea.isHidden
      command.isSelected = !navigatorArea.isHidden
    }
    changeNavigatorAreaVisabilityCommand.title = navigatorArea?.isHidden ?? true ? "Show Navigator Area" : "Hide Navigator Area"
    changeNavigatorAreaVisabilityCommand.groupName = workbenchAreaGroup.name
    changeNavigatorAreaVisabilityCommand.isSelected = !(navigatorArea?.isHidden ?? true)
    
    CommandManager.shared.registerCommand(command: changeNavigatorAreaVisabilityCommand)
    
    //Command to show/hide Debug Area
    let bottomAreaIcon = Bundle.main.image(forResource: "bottomArea")?.imageWithTint(color)
    
    let changeDebugAreaVisabilityCommand = Command(name: "ChangeDebugAreaVisabilityCommand", menuPath: "View", toolbarIcon: bottomAreaIcon) {[weak self] command in
      guard let debugArea = self?.debugArea else { return }
      let title = debugArea.isHidden ? "Hide Debug Area" : "Show Debug Area"
      command.title = title
      debugArea.isHidden = !debugArea.isHidden
      command.isSelected = !debugArea.isHidden
    }
    changeDebugAreaVisabilityCommand.title = debugArea?.isHidden ?? true ? "Show Debug Area" : "Hide Debug Area"
    changeDebugAreaVisabilityCommand.groupName = workbenchAreaGroup.name
    changeDebugAreaVisabilityCommand.isSelected = !(debugArea?.isHidden ?? true)
    
    CommandManager.shared.registerCommand(command: changeDebugAreaVisabilityCommand)
    
    
    //Command to show/hide Inspector Area
    let rightSideBarIcon = Bundle.main.image(forResource: "rightSideBar")?.imageWithTint(color)
    
    let changeInspectorAreaVisabilityCommand = Command(name: "ChangeInspectorAreaVisabilityCommand", menuPath: "View", toolbarIcon: rightSideBarIcon) { [weak self] command in
      guard let inspectorArea = self?.inspectorArea else { return }
      let title = inspectorArea.isHidden ? "Hide Inspector Area" :  "Show Inspector Area"
      command.title = title
      inspectorArea.isHidden = !inspectorArea.isHidden
      command.isSelected = !inspectorArea.isHidden
    }
    
    changeInspectorAreaVisabilityCommand.title = inspectorArea?.isHidden ?? true ? "Show Inspector Area" : "Hide Inspector Area"
    changeInspectorAreaVisabilityCommand.groupName = workbenchAreaGroup.name
    changeInspectorAreaVisabilityCommand.isSelected = !(inspectorArea?.isHidden ?? true)
    
    CommandManager.shared.registerCommand(command: changeInspectorAreaVisabilityCommand)
    
    
    workbenchAreaGroup.commands.append(contentsOf: [changeNavigatorAreaVisabilityCommand, changeDebugAreaVisabilityCommand, changeInspectorAreaVisabilityCommand])
    CommandManager.shared.registerGroup(group: workbenchAreaGroup)
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

//MARK: - NSToolbarDelegate

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
    for command in CommandManager.shared.commands {
      if command.name == itemIdentifier.rawValue {
        return toolbarPushButton(identifier: itemIdentifier, for: command)
      }
    }
    for (name, group) in CommandManager.shared.groups {
      if name == itemIdentifier.rawValue {
        return toolbarSegmentedControl(identifier: itemIdentifier,for: group)
      }
    }
    return nil
  }
  
  public func toolbarWillAddItem(_ notification: Notification) {
    guard let newItem = notification.userInfo?["item"] as? NSToolbarItem else { return }
    if let command = CommandManager.shared.commands.first(where: {$0.name == newItem.itemIdentifier.rawValue}) {
      command.observers.add(observer: self)
    } else if let command = CommandManager.shared.commands.first(where: {$0.groupName == newItem.itemIdentifier.rawValue }), let groupName = command.groupName, let group = CommandManager.shared.groups[groupName] {
      for command in group.commands {
        command.observers.add(observer: self)
      }
    }
    
  }
  
  public func toolbarDidRemoveItem(_ notification: Notification) {
    guard let newItem = notification.userInfo?["item"] as? NSToolbarItem else { return }
    if let command = CommandManager.shared.commands.first(where: {$0.name == newItem.itemIdentifier.rawValue}) {
      command.observers.remove(observer: self)
    } else if let command = CommandManager.shared.commands.first(where: {$0.groupName == newItem.itemIdentifier.rawValue }), let groupName = command.groupName, let group = CommandManager.shared.groups[groupName] {
      for command in group.commands {
        command.observers.remove(observer: self)
      }
    }
  }
  
  private func toolbarSegmentedControl(identifier: NSToolbarItem.Identifier, for group: CommandGroup) -> NSToolbarItemGroup {
    let control = NSSegmentedControl(frame: NSRect(x:0, y:0, width: 38.0 * Double(group.commands.count), height: 28.0))
    control.cell = NimbleSegmentedCell()
    control.trackingMode = .selectAny
    control.segmentCount = group.commands.count
    
    
    let objcWrapper = NSObjectGroupWrapper(wrapperedGroup: group, control: control)
    toolbarGroups.append(objcWrapper)
    control.target = objcWrapper
    control.action = #selector(objcWrapper.execute)
    
    
    var items = [NSToolbarItem]()
    for (segmentIndex, segment) in group.commands.enumerated() {
      guard segment.toolbarIcon != nil else { continue }
      let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(segment.name))
      items.append(item)
      
      control.setImage(segment.toolbarIcon, forSegment: segmentIndex)
      control.setTag(segmentIndex, forSegment: segmentIndex)
      control.setWidth(38.0, forSegment: segmentIndex)
      control.setSelected(segment.isSelected, forSegment: segmentIndex)
    }
    
    let itemGroup = NSToolbarItemGroup(itemIdentifier: identifier)
    itemGroup.paletteLabel = group.name
    itemGroup.subitems = items
    itemGroup.view = control
    return itemGroup
  }
  
  private func toolbarPushButton(identifier: NSToolbarItem.Identifier, for command: Command) -> NSToolbarItem {
    let item = NSToolbarItem(itemIdentifier: identifier)
    item.label = command.name
    item.paletteLabel = command.name
    //TODO: Change color when system theme is changed
    let button = NSButton()
    button.cell = ButtonCell()
    button.image = command.toolbarIcon
    button.action = #selector(command.execute)
    button.target = command
    let width: CGFloat = 38.0
//    let height: CGFloat = 28.0
    button.widthAnchor.constraint(equalToConstant: width).isActive = true
//    button.heightAnchor.constraint(equalToConstant: height).isActive = true
    button.title = ""
    button.imageScaling = .scaleProportionallyDown
    button.bezelStyle = .texturedRounded
    button.focusRingType = .none
    item.view = button
    item.isEnabled = command.isEnable
    return item
  }
}


//MARK: - CommandObserver

extension NimbleWorkbench : CommandObserver {
  public func commandDidChange(_ command: Command) {
    for item in toolbar.items {
      if item.itemIdentifier.rawValue == command.name {
        DispatchQueue.main.async {
          item.isEnabled = command.isEnable
        }
        return
      } else if let groupName = command.groupName, item.itemIdentifier.rawValue == groupName, let group = toolbarGroups.first(where: {$0.name == groupName}) {
          let segmentedControl = group.segmentedControl
          for (index, command) in group.commands.enumerated() {
            if segmentedControl.selectedSegment == index {
              segmentedControl.setEnabled(command.isEnable, forSegment: index)
              segmentedControl.setSelected(command.isSelected, forSegment: index)
            }
          }
        return
      } else {
        continue
      }
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

fileprivate class NSObjectGroupWrapper: NSObject {
  private let wrapperedGroup: CommandGroup
  let segmentedControl: NSSegmentedControl
  
  var name : String {
    return wrapperedGroup.name
  }
  
  var commands: [Command] {
    return wrapperedGroup.commands
  }
  
  init(wrapperedGroup: CommandGroup, control: NSSegmentedControl) {
    self.wrapperedGroup = wrapperedGroup
    self.segmentedControl = control
    super.init()
  }
  
  @objc func execute(_ sender: Any?) {
    wrapperedGroup.commands[segmentedControl.selectedSegment].execute()
  }
  
}


class NimbleSegmentedCell: NSSegmentedCell {
  
  override func drawSegment(_ segment: Int, inFrame frame: NSRect, with controlView: NSView) {
    guard let imageSize = image(forSegment: segment)?.size else { return }
    
    let imageRect = computeImageRect(imageSize: imageSize, in: frame)
    
    let selectedColor = NSColor(named: "SelectedSegmentColor", bundle: Bundle.main)
    let defaulColor = NSColor(named: "BottonIconColor", bundle: Bundle.main)
    let tintColor: NSColor = (isSelected(forSegment: segment) ? selectedColor : defaulColor) ?? .darkGray
    
    if let image = image(forSegment: segment)?.imageWithTint(tintColor) {
      //paddings is equal 2
      image.draw(in: imageRect.insetBy(dx: 2, dy: 2))
    }
  }
  
  func computeImageRect(imageSize: NSSize, in frame: NSRect) -> NSRect {
    var targetScaleSize = frame.size
    
    //Scale proportionally down
    if targetScaleSize.width > imageSize.width { targetScaleSize.width = imageSize.width }
    if targetScaleSize.height > imageSize.height { targetScaleSize.height = imageSize.height }
    
    let scaledSize = self.sizeByScalingProportianlly(toSize: targetScaleSize, fromSize: imageSize)
    let drawingSize = NSSize(width: scaledSize.width, height: scaledSize.height)
    
    //Image position inside the content frame (center)
    let drawingPosition = NSPoint(x: frame.origin.x + frame.size.width / 2 - drawingSize.width / 2,
                                  y: frame.origin.y + frame.size.height / 2 - drawingSize.height / 2)

    return NSRect(x: round(drawingPosition.x), y: round(drawingPosition.y), width: ceil(drawingSize.width), height: ceil(drawingSize.height))
    
  }
  
  
  func sizeByScalingProportianlly(toSize newSize: NSSize, fromSize oldSize: NSSize) -> NSSize {
      let widthHeightDivision = oldSize.width / oldSize.height
      let heightWidthDivision = oldSize.height / oldSize.width

      var scaledSize = NSSize.zero

      if oldSize.width > oldSize.height {
          if (widthHeightDivision * newSize.height) >= newSize.width {
              scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
          } else {
              scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
          }
      } else {
          if (heightWidthDivision * newSize.width) >= newSize.height {
              scaledSize = NSSize(width: widthHeightDivision * newSize.height, height: newSize.height)
          } else {
              scaledSize = NSSize(width: newSize.width, height: heightWidthDivision * newSize.width)
          }
      }

      return scaledSize
  }
}
