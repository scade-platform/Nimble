//
//  Plugin.swift
//  LSPClient.plugin
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

import NimbleCore
import LSPClient


public final class LSPClientModule: Module {
  public static let plugin: Plugin = LSPClientPlugin()
}


final class LSPClientPlugin: Plugin {
  func load() { }
  
  public func activate(in workbench: Workbench) {
    LSPServerManager.shared.connect(to: workbench)
  }
  
  public func deactivate(in workbench: Workbench) {
    LSPServerManager.shared.disconnect(from: workbench)
  }
}
