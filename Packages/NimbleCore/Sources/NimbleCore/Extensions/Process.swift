//
//  Process.swift
//  NimbleCore
//
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

public enum ExecError: Error {
    case exitCodeError(Int32)
}

public extension Process {
  static func exec(_ path: String, arguments: [String] = [], environment: [String:String] = [:]) throws -> String? {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: path)
    proc.arguments = arguments
    proc.environment = environment

    let pipe = Pipe()
    proc.standardOutput = pipe

    try proc.run()
    proc.waitUntilExit()

    if (proc.terminationStatus != 0) {
      throw ExecError.exitCodeError(proc.terminationStatus)
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }

  func exec() throws -> String? {
    let pipe = Pipe()
    self.standardOutput = pipe

    try self.run()
    self.waitUntilExit()

    if (self.terminationStatus != 0) {
      throw ExecError.exitCodeError(self.terminationStatus)
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }
}


