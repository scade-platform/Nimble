//
//  File.swift
//  Contains definitions of SPM package reader classes.
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

import Foundation
import NimbleCore


public struct SPMPackageReaderPackage: Codable {
  var name: String
  var products: [SPMPackageReaderProduct]
  var targets: [SPMPackageReaderTarget]
}

public struct SPMPackageReaderProduct: Codable {
  var name: String
  var type: [String: [String]?]

  public var isExecutable: Bool {
      guard let typeStr = type.first?.key else { return false }
      return typeStr == "executable"
  }
}

public struct SPMPackageReaderTarget: Codable {
  var name: String
}


// SPM package reader that uses "swift package dump-package" command to dump SPM
// package to JSON and parses list of targets/product from JSON dumped.
public class SPMPackageReader {
  // Path to project folder
  public private(set) var path: Path

  // Initializes reader with specified path to project
  public init(path: Path) {
    self.path = path
  }

  // Reads package contents
  public func read() throws -> SPMPackageReaderPackage {
    // dumping package json using swift package command
    let proc = ProcessBuilder(exec: "/usr/bin/swift")
      .environment(key: "PATH", value: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin")
      .currentDirectory(path: self.path.string)
      .arguments("package", "dump-package")
      .build()
    let packageJSONDump = try proc.exec()

    guard let packageJSONDump = packageJSONDump else {
      throw NSError(domain: "SPMPackageReader",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Process.exec returned null"])
    }

    if packageJSONDump.isEmpty {
      throw NSError(domain: "SPMPackageReader",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "package manifest dump is empty"])
    }

    guard let content = packageJSONDump.data(using: .utf8) else {
      throw NSError(domain: "SPMPackageReader",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "can't convert package dump result to string"])
    }

    do {
      return try JSONDecoder().decode(SPMPackageReaderPackage.self, from: content)
    }
    catch {
      throw NSError(domain: "SPMPackageReader",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "can't parse package manifest dump: \(error)"])
    }
  }
}

