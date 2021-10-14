//
//  Xcode.swift
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

import Foundation
import Path

public class Xcode {
  public static var developerDirectory: Path? {
    getPathToXcodeDeveloperDirectory()
  }
  
  public static var toolchainDirectory: Path? {
    getPathToXcodeToolchain()
  }
  
  private static func getPathToXcodeToolchain() -> Path? {
    guard let pathToXcodeDeveloperDirectory = developerDirectory else {
      return nil
    }
    return pathToXcodeDeveloperDirectory/"Toolchains/XcodeDefault.xctoolchain"
  }

  private static func getPathToXcodeDeveloperDirectory() -> Path? {
    guard let commandOutput = try? Process.exec("/usr/bin/xcode-select", arguments:  ["-p"]) else {
      return nil
    }
    
    guard let path = Path(commandOutput) else {
      return nil
    }
    
    return path
  }
}
