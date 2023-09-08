//
//  WorkbenchProcess.swift
//  Contains definition of the WorkbenchProcess class and related classes.
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


// Represents external process which is running in a workbench
open class WorkbenchProcess {
  public var observers = ObserverSet<WorkbenchTaskObserver>()
  private var terminationHandler: ((WorkbenchProcess) -> Void)?

  private let process: Process
  private var console: Console?

  // Initializes workbench process
  public init(executablePath: Path,
              currentDirectory: Path,
              arguments: [String] = [],
              environment: [String: String] = [:]) {
    // creating process object and settings main parameters
    self.process = Process()
    self.process.executableURL = executablePath.url
    self.process.currentDirectoryURL = currentDirectory.url
    self.process.arguments = arguments

    // adding process environment if not empty
    if !environment.isEmpty {
      var newEnv = ProcessInfo.processInfo.environment
      for (key, val) in environment {
        newEnv[key] = val
      }

      self.process.environment = newEnv
    }

    // setting process termination handler
    self.process.terminationHandler = { [weak self] proc in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          fatalError("WorkbenchProcess instance should be live here")
        }

        // executing user termination handler
        self.terminationHandler?(self)

        if let console = self.console {
          // logging process exit code to console
          console.writeLine(string: "Process finished with exit code: \(process.terminationStatus)")

          // stop reading process output in console
          console.stopReadingFromBuffer()
        }

        // notifying observers
        self.observers.notify {
          $0.taskDidFinish(self, result: self.process.terminationStatus == 0)
        }
      }
    }
  }

  // Sets termination handler
  public func setTerminationHandler(handler: @escaping (WorkbenchProcess) -> Void) {
    assert(!process.isRunning)
    terminationHandler = handler
  }

  // Redirects process output to console
  public func redirectOutput(to console: Console) {
    assert(!process.isRunning)

    self.console = console
    
    let pipe = Pipe()
    pipe.fileHandleForReading.readabilityHandler = {fh in
      let data = fh.availableData
      if !data.isEmpty {
        console.write(data: data)
      }
    }

    process.standardOutput = pipe
    process.standardError = pipe

    assert(!console.isReadingFromBuffer)
    console.startReadingFromBuffer()
  }

  // Returns process termination status
  public var terminationStatus: Int32 {
    return process.terminationStatus
  }
}

extension WorkbenchProcess: WorkbenchTask {
  public var isRunning: Bool {
    process.isRunning
  }

  public func stop() {
    process.terminate()
  }

  public func run() {
    // notifying observers about task start
    DispatchQueue.main.async {
      self.observers.notify {
        $0.taskDidStart(self)
      }
    }

    // logging task parameters to console
    DispatchQueue.main.async {
      if let url = self.process.executableURL {
        let argsString = self.process.arguments?.map{"\"\($0)\""}.joined(separator: " ") ?? ""
        self.console?.writeLine(string: url.path + " " + argsString)
      }
    }

    do {
      try process.run()
    } catch {
      let nsError = error as NSError

      DispatchQueue.main.async {
        // logging error to console
        if let console = self.console {
          if nsError.domain == "NSCocoaErrorDomain", nsError.code == 4, let filePath = nsError.userInfo["NSFilePath"] {
            console.writeLine(string: "Error: The file \"\(filePath)\" doesn’t exist.")
          } else {
            console.write(string: "Error: ").writeLine(obj: error)
          }
        }

        // stop reading from process output in console
        if let console = self.console {
          console.stopReadingFromBuffer()
        }

        // notifying observers about task finish
        self.observers.notify {
          $0.taskDidFinish(self, result: false)
        }
      }
    }
  }
}
