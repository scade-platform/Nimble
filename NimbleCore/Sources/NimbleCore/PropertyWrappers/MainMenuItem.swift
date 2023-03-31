//
//  MainMenuItem.swift
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

@propertyWrapper
public struct MainMenuItem {
  public var wrappedValue: NSMenuItem? {
    findItem(by: menuPath)
  }
  
  private let menuPath: String
  
  public init(_ path: String) {
    self.menuPath = path
  }
  
  private func findItem(by path: String) -> NSMenuItem? {
    guard let mainMenu = NSApp.mainMenu else {
      return nil
    }
    
    let realPath = replacePatterns(in: path)
    
    guard let item = mainMenu.findItem(with: realPath) else {
      return nil
    }
    
    return item
  }
  
  private func replacePatterns(in path: String) -> String {
    var resultPath: String = path
    for pattern in Patterns.allCases {
      if path.contains(pattern.rawValue) {
        resultPath = resultPath.replacingOccurrences(of: pattern.rawValue, with: pattern.replacement)
      }
    }
    return resultPath
  }
  
  
  public enum Patterns: String, CaseIterable {
    case appName = "{APP_NAME}";
    
    fileprivate var replacement: String {
      switch self {
      case .appName:
        let currentAppName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        return currentAppName
      }
    }
    
    public static func / (lhs: Patterns, rhs: String) -> String {
      lhs.rawValue + "/" + rhs
    }
  }
}
