//
//  DefaultShellBuildTool.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Foundation
import NimbleCore


class ShellBuildTool: BuildTool {
  var name: String {
    return "Shell"
  }
  
  func run(in workbench: Workbench) -> BuildProgress {
    guard let fileURL = workbench.currentDocument?.fileURL else {
      return FailureBuild()
    }
    let shellProc = Process()
    shellProc.currentDirectoryURL = fileURL.deletingLastPathComponent()
    shellProc.executableURL = URL(fileURLWithPath: "/bin/sh")
    shellProc.arguments = [fileURL.path]
    var progress = ShellBuildProgress(status: .running)
    
    //reaction of the build on status changes
    progress.subscribe(handler: { status in
      if status == .cancelled, shellProc.isRunning {
        shellProc.terminate()
      } else if status == .paused, shellProc.isRunning {
        shellProc.suspend()
      } else if status == .running {
        shellProc.resume()
      }
    })
    
    //build finish
    shellProc.terminationHandler = { process in
      if process.terminationReason == .exit {
        progress.status = .finished
      } else {
        progress.status = .failure
      }
    }
    try? shellProc.run()
    return progress
  }
}

public struct ShellBuildProgress: MutableBuildProgress {
  private var subscribers: [(BuildProgressStatus) -> Void] = []
  public internal(set) var status: BuildProgressStatus {
    didSet {
      subscribers.forEach{ $0(self.status)}
      if status == .cancelled || status == .finished || status == .failure {
        //last status for this progress
        subscribers.removeAll()
      }
    }
  }
  
  public var isCancellable: Bool {
    return true
  }
  
  public var isPausable: Bool {
    return true
  }
  
  public mutating func subscribe(handler: @escaping (BuildProgressStatus) -> Void) {
    subscribers.append(handler)
  }
  
  init(status: BuildProgressStatus) {
    self.status = status
  }
  
  public mutating func cancel() {
    if isCancellable {
      status = .cancelled
    }
  }
  
  public mutating func pause() {
    if isPausable {
       status = .paused
    }
  }
  
  public mutating func resume() {
    if status == .paused {
      status = .running
    }
  }
}
