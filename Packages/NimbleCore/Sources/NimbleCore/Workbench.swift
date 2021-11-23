//
//  Workbench.swift
//  StudioCore
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

// MARK: - Workbench

public protocol Workbench: AnyObject {
  var project: Project? { get }
  
  var documents: [Document] { get }
  
  var currentDocument: Document? { get }
  
  var observers: ObserverSet<WorkbenchObserver> { get set }
  
  var diagnostics: [DiagnosticSource: [Diagnostic]] { get }

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

  func publish(diagnostics: [Diagnostic], for: DiagnosticSource)

  func publish(task: WorkbenchTask)

  func publish(task: WorkbenchTask, onComplete: @escaping (WorkbenchTask) -> Void)

  func invalidateRestorableState()
}

public extension Workbench {
  var id: ObjectIdentifier { ObjectIdentifier(self) }
  
  var areas: [WorkbenchArea] { [navigatorArea, debugArea, inspectorArea].compactMap{$0} }

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

  func publish(diagnostics: [Diagnostic], for path: Path) {
    publish(diagnostics: diagnostics, for: .path(path))
  }

  func publish(diagnosticMessage: String, severity: DiagnosticSeverity, source: DiagnosticSource) {
    publish(diagnostics: [WorkbenchDiagnostic(message: diagnosticMessage, severity: severity)], for: source)
  }

  func diagnostics(severity: DiagnosticSeverity) -> [DiagnosticSource: [Diagnostic]] {
    var res = [DiagnosticSource: [Diagnostic]]()
    diagnostics.forEach { d in
      let selection = d.value.filter{$0.severity == severity}
      if !selection.isEmpty {
        res[d.key] = selection
      }
    }
    return res
  }
}

public protocol WorkbenchObserver: AnyObject {
  func workbenchWillChangeProject(_ workbench: Workbench)
  func workbenchDidChangeProject(_ workbench: Workbench)
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document)
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document)
  func workbenchWillSaveDocument(_ workbench: Workbench, document: Document)
  func workbenchDidSaveDocument(_ workbench: Workbench, document: Document)
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?)
  func workbenchDidPublishDiagnostic(_ workbench: Workbench, diagnostic: [Diagnostic], source: DiagnosticSource)
}

public extension WorkbenchObserver {
  func workbenchWillChangeProject(_ workbench: Workbench) { return }
  func workbenchDidChangeProject(_ workbench: Workbench) { return }
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchWillSaveDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchDidSaveDocument(_ workbench: Workbench, document: Document) { return }
  func workbenchActiveDocumentDidChange(_ workbench: Workbench, document: Document?) { return }
  func workbenchDidPublishDiagnostic(_ workbench: Workbench, diagnostic: [Diagnostic], source: DiagnosticSource) { return }
}

// MARK: - Area

public protocol WorkbenchArea: AnyObject {
  var parts: [WorkbenchPart] { get }
  var isHidden: Bool { get set }

  func add(part: WorkbenchPart) -> Void
  func show(part: WorkbenchPart) -> Void
}


public extension WorkbenchArea {
  func show() { isHidden = false }
  func hide() { isHidden = true }
}


// MARK: - Part

public protocol WorkbenchPart: AnyObject {
  var view: NSView { get }
  var title: String? { get }
  var icon: NSImage? { get }
  var workbench: Workbench? { get }
}

public extension WorkbenchPart {
  func show() {
    guard let area = (self as? NSViewController)?.parent as? WorkbenchArea else { return }

    area.show()
    area.show(part: self)
  }
}


// MARK: - StatusBar

public protocol WorkbenchStatusBar: AnyObject {
  var leftBar : [WorkbenchStatusBarItem] { get set }
  var rightBar: [WorkbenchStatusBarItem] { get set }

  var statusMessage: String { get set }

  func setStatusMessage(_ message: String, duration: Int)
}

public protocol WorkbenchStatusBarItem { }



// MARK: - Tasks and processes

public protocol WorkbenchTask: AnyObject {
  var observers: ObserverSet<WorkbenchTaskObserver> { get set }
  var isRunning: Bool { get }

  func stop()
  func run() throws
}

public extension WorkbenchTask {
  var id: ObjectIdentifier {
    return ObjectIdentifier(self)
  }
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
  public private(set) var console: Console?
  public var observers = ObserverSet<WorkbenchTaskObserver>()
  var consoleWillCloseHandler: ((Console) -> Void)?
  var userTerminationHandler: ((Process) -> Void)?
  
  public init(_ process: Process) {
    self.process = process
    self.userTerminationHandler = process.terminationHandler
    self.process.terminationHandler = { [weak self] proc in
      guard let self = self else { return }
      //Call user termination handler
      self.userTerminationHandler?(proc)
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.observers.notify {
          $0.taskDidFinish(self)
        }
      }
    }
  }
  
  @discardableResult
  public func output(to console: Console, consoleWillCloseHandler handler: @escaping (Console) -> Void = {_ in }) -> Console? {
    guard !process.isRunning else {
      return nil
    }
    self.console = console
    self.consoleWillCloseHandler = handler
    
    let pipe = Pipe()
    pipe.fileHandleForReading.readabilityHandler = {fh in
      let data = fh.availableData
      if !data.isEmpty {
        console.write(data: data)
      }
    }
    
    process.standardOutput = pipe
    process.standardError = pipe
    
    if !console.isReadingFromBuffer {
      console.startReadingFromBuffer()
    }
    process.terminationHandler = {[weak self] proc in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        
        //Call user termination handler
        self.userTerminationHandler?(proc)
        
        if let console = self.console {
          handler(console)
          
          if console.contents.isEmpty {
            console.close()
          }
        }
        self.observers.notify {
          $0.taskDidFinish(self)
        }
      }
    }
    return self.console
  }
}

extension WorkbenchProcess: WorkbenchTask {
  public var isRunning: Bool { process.isRunning }
  public func stop() { process.terminate() }
  public func run() throws {
    do {
      try process.run()
    } catch {
      let nsError = error as NSError
      if let console = console {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          if nsError.domain == "NSCocoaErrorDomain", nsError.code == 4, let filePath = nsError.userInfo["NSFilePath"] {
            console.writeLine(string: "Error: The file \"\(filePath)\" doesn’t exist.")
          } else {
            console.write(string: "Error: ").writeLine(obj: error)
          }
          self.consoleWillCloseHandler?(console)
        }
      }
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        //We can run the process after save it in Workbench
        //so we need to release resources even though the process doesn't start
        self.observers.notify {
          $0.taskDidFinish(self)
        }
      }
      throw error
    }
    self.observers.notify {
      $0.taskDidStart(self)
    }
  }
}
