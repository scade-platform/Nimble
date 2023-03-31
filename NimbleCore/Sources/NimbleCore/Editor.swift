//
//  Editor.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

///TODO: avoid constraining the protocol to the NSViewController
public protocol WorkbenchEditor: NSViewController {
  ///TODO: replace by Commands
  // Shown within the app's main menu
  static var editorMenu: NSMenu? { get }

  var workbench: Workbench? { get }

  var statusBarItems: [WorkbenchStatusBarItem] { get }
  
  @discardableResult
  func focus() -> Bool
  
  func publish(diagnostics: [Diagnostic])
}


public extension WorkbenchEditor {
  static var editorMenu: NSMenu? { return nil }

  var workbench: Workbench? {
    return view.window?.windowController as? Workbench
  }

  var statusBarItems: [WorkbenchStatusBarItem] { return [] }
  
  func focus() -> Bool {
    return view.window?.makeFirstResponder(view) ?? false
  }
  
  func publish(diagnostics: [Diagnostic]) { }
  
  //func didOpenDocument(_ document: Document) { }
}

// MARK: - Editor Command Actions

public protocol WorkbenchEditorZoomSupport where Self: WorkbenchEditor {
  func zoomIn()
  func zoomOut()
  func zoomActualSize()
}

public protocol WorkbenchEditorZoomToFitSupport where Self: WorkbenchEditor {
  func zoomToFit()
}
