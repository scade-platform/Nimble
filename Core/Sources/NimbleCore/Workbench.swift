//
//  Workbench.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa

public protocol Workbench {
  var project: Project { get }
  
  var navigatorArea: WorkbenchArea? { get }

//  var inspectorArea: WorkbenchPart { get }
//
//  var toolbarArea: WorkbenchPart { get }
//
//  var debugArea: WorkbenchPart { get }
  
  @discardableResult
  func open(file: File) -> Document?
  
}

public protocol WorkbenchDelegate {
  func projectHasChanged(project: Project)
}

public extension WorkbenchDelegate {
  func projectHasChanged(project: Project){
    //by default do nothing
  }
}

public protocol WorkbenchArea: WorkbenchDelegate {
  func add(part: WorkbenchPart) -> Void
}


public protocol WorkbenchPart: WorkbenchDelegate {
  var view: NSView { get }
  
  var title: String { get }
  
  var icon: NSImage? { get }
}
