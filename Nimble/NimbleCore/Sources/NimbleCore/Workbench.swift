//
//  Workbench.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public protocol Workbench where Self : NSWindowController {
  var navigatorArea: WorkbenchArea? { get }

//  var inspectorArea: WorkbenchPart { get }
//
//  var toolbarArea: WorkbenchPart { get }
//
  
  var debugArea: WorkbenchArea? { get }
  
  func open(document: Document, preview: Bool)
  
  func show(unsupported file: File)
  
  func close(document: Document)
  
  func createConsole(title: String, show: Bool) -> Console?
  
  func addWorkbenchObserver(_ observer: WorkbenchObserver)
  
  func removeWorkbenchObserver(_ observer: WorkbenchObserver)
}

public extension Workbench {
  var project: Project? {
    return ProjectController.shared.project(for: self)
  }
  
  var projectDocument: ProjectDocumentProtocol? {
    return ProjectController.shared.projectDocument(for: self)
  }
  
  var projectNotificationCenter: ProjectNotificationCenter? {
    return projectDocument?.notificationCenter
  }
  
  func open(document: Document) {
    self.open(document: document, preview: false)
  }
  
  func preview(document: Document) {
    self.open(document: document, preview: true)
  }
  
  func open(file: File) -> Document? {
    guard let document = try? file.open() else {
      show(unsupported: file)
      return nil
    }
    self.open(document: document)
    return document
  }
  
  func preview(file: File) -> Document? {
    guard let document = try? file.open() else {
      show(unsupported: file)
      return nil
    }
    self.preview(document: document)
    return document
  }
}

public protocol WorkbenchArea {
  func add(part: WorkbenchPart) -> Void
}

public protocol Hideable {
  var isHidden: Bool { get set }
}


public protocol WorkbenchPart {
  var view: NSView { get }
  
  var title: String? { get }
  
  var icon: NSImage? { get }
}


public protocol WorkbenchObserver : class {
  func documentDidSelect(_ document: Document)
  func documentDidOpen(_ document: Document)
  func documentDidClose(_ document: Document)
  func documentDidChange(_ document: Document)
  func documentDidSave(_ document: Document)
}

public extension WorkbenchObserver {
  func documentDidSelect(_ document: Document) {}
  func documentDidOpen(_ document: Document) {}
  func documentDidClose(_ document: Document) {}
  func documentDidChange(_ document: Document) {}
  func documentDidSave(_ document: Document) {}
}
