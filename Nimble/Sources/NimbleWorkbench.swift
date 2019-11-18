//
//  NimbleWorkbench.swift
//  Nimble
//
//  Created by Grigory Markin on 01.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


// MARK: - Nimble workbench

public class NimbleWorkbench: NSWindowController, NSWindowDelegate {
  public var observers = ObserverSet<WorkbenchObserver>()
  
  public override var document: AnyObject? {
    get { super.document }
    set {
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
    
    guard let debugView = debugView else { return }
    debugView.isHidden = true
    
    PluginManager.shared.activate(in: self)
  }
    
  public func windowWillClose(_ notification: Notification) {
    PluginManager.shared.deactivate(in: self)
  }
  
  
  public func open(_ url: URL) {
    guard let path = Path(url: url) else { return }
    open(path)
  }
  
  public func openAll(_ urls: [URL]) {
    urls.forEach { open($0) }
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



extension NimbleWorkbench: Workbench {
  public var project: Project? {
    return (document as? ProjectDocument)?.project
  }
  
  
  public var navigatorArea: WorkbenchArea? {
    return navigatorView
  }
  
  public var debugArea: WorkbenchArea? {
     return debugView
  }
  
  
  public var activeDocument: Document? {
    return editorView?.currentDocument
  }
  
  public var openedDocuments: [Document] {
    return editorView?.documents ?? []
  }
  
  
  public func open(_ path: Path) {
    ///TODO: implement
    print("Opening \(path)")
  }
     
  
  public func open(_ doc: Document, show: Bool) {
    guard let editorView = editorView else { return }
        
    if openedDocuments.count == 0 {
      editorView.addTab(doc)
      
    } else if show {
      if let index = editorView.findIndex(doc) {
        editorView.selectTab(index)
        
      } else if let edited = activeDocument?.isDocumentEdited, edited {
        editorView.insertTab(doc, at: editorView.currentIndex! + 1)
        
      } else {
        editorView.show(doc)
      }
      
    } else if editorView.findIndex(doc) == nil {
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


// MARK: - Nimble workbench area

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



// MARK: - Nimble workbench view and controller

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
