//
//  Xcode.swift
//  
//
//  Created by Danil Kristalev on 26.07.2021.
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
