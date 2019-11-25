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
  
  public override var document: AnyObject? {
    get { super.document }
    set {
      observers.notify { $0.workbenchWillChangeProject(self) }
      super.document = newValue
      observers.notify { $0.workbenchDidChangeProject(self) }
    }
  }
  
  var workbenchView: NSSplitViewController? {
    contentViewController as? NSSplitViewController
  }
      
  var workbenchCentralView: NSSplitViewController? {
    workbenchView?.children[1] as? NSSplitViewController
  }
  
  var navigatorView: NavigatorView? {
    workbenchView?.children[0] as? NavigatorView
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
    
    PluginManager.shared.activate(in: self)
  }
    
  public func windowWillClose(_ notification: Notification) {
    PluginManager.shared.deactivate(in: self)
  }
  
  private func showSaveDialog(question: String, text: String) -> (save: Bool, close: Bool) {
    let alert = NSAlert()
    
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    
    alert.addButton(withTitle: "Save")
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Don't Save")
    
    let result = alert.runModal()
    return (save: result == .alertFirstButtonReturn,
            close: result == .alertThirdButtonReturn || result == .alertFirstButtonReturn)
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
        editorView.show(doc)
      }
    
    // Just insert a tab but not switch to it
    } else if editorView.findTab(doc) == nil {
      editorView.insertTab(doc, at: editorView.currentIndex!, select: false)
    }
    
    observers.notify { $0.workbenchDidOpenDocument(self, document: doc) }
  }
  
    
  public func close(_ doc: Document) -> Bool {
    var close = true
    
    if doc.isDocumentEdited {
      let result = showSaveDialog(
        question: "Do you want to save the changes you made to \(doc.title)?",
        text: "Your changes will be lost if you don't save them"
      )
      
      if result.save {
        doc.save(nil)
      }
      
      close = result.close
    }
    
    editorView?.removeTab(doc)
    observers.notify { $0.workbenchDidCloseDocument(self, document: doc) }
    
    return close
  }
  
  
  public func createConsole(title: String, show: Bool) -> Console? {
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
  
  @objc func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
    guard let menuId = (item as? NSMenuItem)?.identifier?.rawValue else { return true }
    switch menuId {
    case "saveMenuItem":
      return currentDocument?.isDocumentEdited ?? false
    case "saveAsMenuItem":
      return currentDocument != nil
    case "saveAllMenuItem":
      return documents.contains{$0.isDocumentEdited}
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
