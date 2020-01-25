//
//  Workbench.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public protocol Workbench: class {
  var project: Project? { get }
  
  var documents: [Document] { get }
  
  var currentDocument: Document? { get }
  
  var observers: ObserverSet<WorkbenchObserver> { get set }
  
  var diagnostics: [Path: [Diagnostic]] { get }
  
  
  var navigatorArea: WorkbenchArea? { get }
  
//  var inspectorArea: WorkbenchPart { get }
//
//  var toolbarArea: WorkbenchPart { get }
//
  
  var debugArea: WorkbenchArea? { get }
    
  var statusBar: WorkbenchStatusBar { get }
  
  var openedConsoles: [Console] { get }
              
  
  func open(_ doc: Document, show: Bool)
  
  func open(_ doc: Document, show: Bool, openNewEditor: Bool)
  
  @discardableResult
  func close(_ doc: Document) -> Bool
  
  func createConsole(title: String, show: Bool) -> Console?
  
  func publishDiagnostics(for path: Path, diagnostics: [Diagnostic])
}


public extension Workbench {
  func open(_ doc: Document, show: Bool) {
    open(doc, show: show, openNewEditor: true)
  }
}


public protocol WorkbenchObserver: class {
  func workbenchWillChangeProject(_ workbench: Workbench)
  func workbenchDidChangeProject(_ workbench: Workbench)
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document)
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document)
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?)
}

public extension WorkbenchObserver {
  func workbenchWillChangeProject(_ workbench: Workbench) { return }
  func workbenchDidChangeProject(_ workbench: Workbench) { return }
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) { return }
}


public protocol WorkbenchArea: class {
  var isHidden: Bool { get set }
  
  func add(part: WorkbenchPart) -> Void
}


public extension WorkbenchArea {
  func show() { isHidden = false }
  func hide() { isHidden = true }
}


public protocol WorkbenchPart: class {
  var view: NSView { get }
  
  var title: String? { get }
  
  var icon: NSImage? { get }
}




public protocol WorkbenchEditor: NSViewController {
  // Shown within the app's main menu
  var editorMenu: NSMenu? { get }
  
  @discardableResult
  func focus() -> Bool
  
  func publish(diagnostics: [Diagnostic])
}


public extension WorkbenchEditor {
  var editorMenu: NSMenu? { nil }
    
  func focus() -> Bool {
    return view.window?.makeFirstResponder(view) ?? false
  }
  
  func publish(diagnostics: [Diagnostic]) {
    
  }
}


public protocol WorkbenchStatusBar {
  var leftBar : [WorkbenchStatusBarCell] { get set }
  var rightBar: [WorkbenchStatusBarCell] { get set }
}


public protocol WorkbenchStatusBarCell {
  var title: String { set get }
}

public struct StatusBarTextCell : WorkbenchStatusBarCell {
  public var title: String
  
  public init(title: String) {
    self.title = title
  }
}
