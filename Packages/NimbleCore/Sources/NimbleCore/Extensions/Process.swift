//
//  File.swift
//  
//
//  Created by Grigory Markin on 07.04.21.
//

import Foundation


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

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }

}
