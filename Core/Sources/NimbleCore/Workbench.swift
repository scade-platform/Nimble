//
//  Workbench.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public protocol Workbench {
  var project: Project? { get }
  
  var navigatorArea: WorkbenchArea? { get }
  
  var changedFiles: [File]? { get }
  
  var consoleController: ConsoleController? { get }

//  var inspectorArea: WorkbenchPart { get }
//
//  var toolbarArea: WorkbenchPart { get }
//
//  var debugArea: WorkbenchPart { get }
  
  @discardableResult
  func open(file: File) -> Document?
  
  func preview(file: File)
  
  func save(file: File)
  
  var isConsoleHidden: Bool { set get }
  
}

public extension Workbench {
  var consoleController:ConsoleController? {
    return ConsoleManager.shared.controllerInstance()
  }
  
  func showConsole(value: Bool){
    //by default do nothing
  }
}

public protocol WorkbenchArea {
  func add(part: WorkbenchPart) -> Void
}


public protocol WorkbenchPart {
  var view: NSView { get }
  
  var title: String { get }
  
  var icon: NSImage? { get }
}
