//
//  NSOpenPanel.swift
//  Nimble
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

extension NSOpenPanel {
  func selectFile(ofTypes allowedTypes: [String]) -> URL? {    
    return selectFiles(ofTypes: allowedTypes).first
  }
  
  func selectFiles(ofTypes allowedTypes: [String]) -> [URL] {
    canChooseFiles = true
    canChooseDirectories = false
    allowsMultipleSelection = false
    canCreateDirectories = false
    if !allowedTypes.isEmpty {
      allowedFileTypes = allowedTypes
    }
    return runModal() == .OK ? urls : []
  }
  
  func selectFolders() -> [URL] {
    canChooseFiles = false
    canChooseDirectories = true
    allowsMultipleSelection = true
    canCreateDirectories = false
    return runModal() == .OK ? urls : []
  }
  
  func selectAny() -> [URL] {
    canChooseFiles = true
    canChooseDirectories = true
    allowsMultipleSelection = true
    canCreateDirectories = false
    return runModal() == .OK ? urls : []
  }
}
