//
//  Launcher.swift
//  
//
//  Created by Danil Kristalev on 21.04.2020.
//

import Foundation

public struct Target {
  public weak var project: Project?
  public let name: String
  public let icon: Icon?
  public let platforms: [LaunchPlatform]
  
  public init(project: Project? = nil, name: String, icon: Icon? = nil, platforms: [LaunchPlatform]){
    self.project = project
    self.name = name
    self.icon = icon
    self.platforms = platforms
  }
}

public protocol LaunchPlatform {
  var name: String { get }
  var icon: Icon? { get }
  var subplatforms: [LaunchPlatform]? { get }
}


public class TargetManager {
  public static let shared = TargetManager()
  private init() {}
  
  private var providers: [LaunchPlatformProvider] = []
  
  public func targets(from workbench: Workbench) -> [Target] {
    return providers.flatMap{$0.targets(for: workbench)}
  }
  
  public func register(provider: LaunchPlatformProvider) {
    providers.append(provider)
  }
}

public protocol LaunchPlatformProvider {
  func targets(for workbench: Workbench) -> [Target]
}
