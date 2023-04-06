//
//  SwiftExtensions.swift
//  SwiftExtensions
//
//  Copyright © 2023 SCADE Inc. All rights reserved.
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

import Foundation
import NimbleCore

public struct Settings: SettingsGroup {
  public static let shared = Settings()

  @SettingDefinition("editor.lsp.servers",
                     description: """
                                  List of exteral Language Servers (LSP).
                                  Default value is empy list.
                                  An external server can be specified using the following structure
                                    - languages: List of supported languages (required)
                                    - executable: Path to the server executable (required)
                                    - arguments: List of arguments that should be passed to the executable (optional)
                                    - environment: Dictionary of environment variables and values for the server process (optional)
                                    - initializationOptions: LSP Any value passed to the server during the init phase, for more details, please, refer to the documentation of the Language Server Protocol (optional)
                                  """,
                     defaultValue: [])
  public private(set) var servers: [LSPExternalServerProvider]
}
