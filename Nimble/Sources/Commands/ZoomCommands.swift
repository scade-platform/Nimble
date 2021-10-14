//
//  ZoomCommand.swift
//  Nimble
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
import NimbleCore

class ZoomCommand : Command {

  override func validate(in workbench: Workbench) -> State {
    return workbench.currentDocument?.editor is WorkbenchEditorZoomSupport ? .default : .disabled
  }

  static func create(name: String , keyEquivalent: String,
                     handler: @escaping (WorkbenchEditorZoomSupport) -> Void) -> Command {
    let command = ZoomCommand(name: name, keyEquivalent: keyEquivalent) { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomSupport else { return }
      handler(editor)
    }
    return command
  }
}

class ZoomToFitCommand : Command {

  override func validate(in workbench: Workbench) -> State {
    return workbench.currentDocument?.editor is WorkbenchEditorZoomToFitSupport ? .default : .disabled
  }

  static func create(name: String , keyEquivalent: String,
                     handler: @escaping (WorkbenchEditorZoomToFitSupport) -> Void) -> Command {
    let command = ZoomToFitCommand(name: name, keyEquivalent: keyEquivalent) { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomToFitSupport else { return }
      handler(editor)
    }
    return command
  }
}

