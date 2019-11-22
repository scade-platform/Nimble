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
  
  var observers: ObserverSet<WorkbenchObserver> { get }

  var navigatorArea: WorkbenchArea? { get }
  
//  var inspectorArea: WorkbenchPart { get }
//
//  var toolbarArea: WorkbenchPart { get }
//
  
  var debugArea: WorkbenchArea? { get }
    
  
  var activeDocument: Document? { get }
  
  var openedDocuments: [Document] { get }
  
              
  
  func open(_ doc: Document, show: Bool)
  
  @discardableResult
  func close(_ doc: Document) -> Bool
  
  
  
  func createConsole(title: String, show: Bool) -> Console?
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



