//
//  NSOpenPanel.swift
//  Nimble
//
//  Created by Grigory Markin on 20.11.19.
//  Copyright © 2019 SCADE. All rights reserved.
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
