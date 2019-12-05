//
//  BuildTool.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public protocol BuildTool {
  var name: String { get }
  func run(in workbench: Workbench) -> BuildProgress
}

public protocol BuildProgress {
  //public clients can't change status directly
  var status: BuildProgressStatus { get }
  var isCancellable: Bool { get }
  var isPausable: Bool { get }
  mutating func subscribe(handler: @escaping (BuildProgressStatus) -> Void)
  mutating func cancel()
  mutating func pause()
  mutating func resume()
}

internal protocol MutableBuildProgress: BuildProgress {
  //but internal clients can
  var status: BuildProgressStatus { get set }
}

//Default implementation for failure build
public struct FailureBuild : BuildProgress {
  public var status: BuildProgressStatus { return .failure }
  public var isCancellable: Bool { return false }
  public var isPausable: Bool { return false }
  public func subscribe(handler: @escaping (BuildProgressStatus) -> Void) {}
  public func cancel() {}
  public func pause() {}
  public func resume() {}
}

public enum BuildProgressStatus {
  case running
  case finished
  case cancelled
  case paused
  case failure
}

public class BuildToolsManager {
  public static let shared = BuildToolsManager()
  
  public private(set) var tools : [BuildTool] = []
  
  private init() {}
  
  public func add(buildTool: BuildTool) {
    tools.append(buildTool)
  }
}
