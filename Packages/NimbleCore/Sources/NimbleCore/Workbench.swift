//
//  Workbench.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

// MARK: - Workbench

public protocol Workbench: class {
  var project: Project? { get }
  
  var documents: [Document] { get }
  
  var currentDocument: Document? { get }
  
  var observers: ObserverSet<WorkbenchObserver> { get set }
  
  var diagnostics: [Path: [Diagnostic]] { get }

  var tasks: [WorkbenchTask] { get }

  var navigatorArea: WorkbenchArea? { get }
  
  var inspectorArea: WorkbenchArea? { get }
  
//  var toolbarArea: WorkbenchPart { get }
//
  
  var debugArea: WorkbenchArea? { get }
    
  var statusBar: WorkbenchStatusBar { get }
  
  var openedConsoles: [Console] { get }
              
  
  func open(_ doc: Document, show: Bool)
  
  func open(_ doc: Document, show: Bool, openNewEditor: Bool)
  
  @discardableResult
  func close(_ doc: Document) -> Bool
  
  func createConsole(title: String, show: Bool, startReading: Bool) -> Console?


  func publish(diagnostics: [Diagnostic], for path: Path)

  func publish(task: WorkbenchTask)
  func publish(task: WorkbenchTask, onComplete: @escaping (WorkbenchTask) -> Void)
}


public extension Workbench {
  static var current: Workbench? {
    NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench
  }

  func open(_ doc: Document, show: Bool) {
    open(doc, show: show, openNewEditor: true)
  }
  
  func willSaveDocument(_ doc: Document) {
    observers.notify {
      $0.workbenchWillSaveDocument(self, document: doc)
    }
  }
  
  func didSaveDocument(_ doc: Document) {
    observers.notify {
      $0.workbenchDidSaveDocument(self, document: doc)
    }
  }
  
  func  createConsole(title: String, show: Bool) -> Console? {
    return createConsole(title: title, show: show, startReading: true)
  }
}


public protocol WorkbenchObserver: class {
  func workbenchWillChangeProject(_ workbench: Workbench)
  func workbenchDidChangeProject(_ workbench: Workbench)
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document)
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document)
  func workbenchWillSaveDocument(_ workbench: Workbench, document: Document)
  func workbenchDidSaveDocument(_ workbench: Workbench, document: Document)
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?)
}

public extension WorkbenchObserver {
  func workbenchWillChangeProject(_ workbench: Workbench) { return }
  func workbenchDidChangeProject(_ workbench: Workbench) { return }
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchWillSaveDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchDidSaveDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) { return }
}

// MARK: - Area

public protocol WorkbenchArea: class {
  var isHidden: Bool { get set }
  
  func add(part: WorkbenchPart) -> Void
}


public extension WorkbenchArea {
  func show() { isHidden = false }
  func hide() { isHidden = true }
}


// MARK: - Part

public protocol WorkbenchPart: class {
  var view: NSView { get }
  
  var title: String? { get }
  
  var icon: NSImage? { get }
}


// MARK: - Editor

///TODO: avoid constraining the protocol to the NSViewController
public protocol WorkbenchEditor: NSViewController {
  var workbench: Workbench? { get }
  
  ///TODO: replace by Commands
  // Shown within the app's main menu
  var editorMenu: NSMenu? { get }
  
  var statusBarItems: [WorkbenchStatusBarItem] { get }
  
  @discardableResult
  func focus() -> Bool
  
  func publish(diagnostics: [Diagnostic])
  
  func didOpenDocument(_ document: Document)
}


public extension WorkbenchEditor {
  var workbench: Workbench? {
    return view.window?.windowController as? Workbench
  }
  
  var editorMenu: NSMenu? { return nil }
  
  var statusBarItems: [WorkbenchStatusBarItem] { return [] }
  
  func focus() -> Bool {
    return view.window?.makeFirstResponder(view) ?? false
  }
  
  func publish(diagnostics: [Diagnostic]) { }
  
  func didOpenDocument(_ document: Document) { }
}


// MARK: - StatusBar

public protocol WorkbenchStatusBar {
  var leftBar : [WorkbenchStatusBarItem] { get set }
  var rightBar: [WorkbenchStatusBarItem] { get set }
}

public protocol WorkbenchStatusBarItem { }



// MARK: - Tasks and processes

public protocol WorkbenchTask: class {
  var observers: ObserverSet<WorkbenchTaskObserver> { get set }
  var isRunning: Bool { get }

  func stop()
  func run() throws
}

public protocol WorkbenchTaskObserver {
  func taskDidFinish(_ task: WorkbenchTask)
  func taskDidStart(_ task: WorkbenchTask)
}

public extension WorkbenchTaskObserver {
  func taskDidFinish(_ task: WorkbenchTask) {}
  func taskDidStart(_ task: WorkbenchTask) {}
}

open class WorkbenchProcess {
  let process: Process
  public var observers = ObserverSet<WorkbenchTaskObserver>()

  public init(_ process: Process) {
    self.process = process
    self.process.terminationHandler = { [weak self] (_: Process) in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.observers.notify {
          $0.taskDidFinish(self)
        }
      }
    }
  }
}

extension WorkbenchProcess: WorkbenchTask {
  public var isRunning: Bool { process.isRunning }
  public func stop() { process.terminate() }
  public func run() throws {
    try process.run()
    self.observers.notify {
      $0.taskDidStart(self)
    }
  }
}

