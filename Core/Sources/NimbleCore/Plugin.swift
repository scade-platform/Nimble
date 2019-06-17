//
//  Plugin.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation


public protocol Module {
  static var pluginClass: Plugin.Type { get }
}


public protocol Plugin {
  init?()
  
  func activate(workbench: Workbench) -> Void
  
  func deactivate() -> Void
}


public class PluginManager {
  private static let modules: [Module.Type] = loadModules()
  
  private var plugins: [Plugin] = []
  
  public static let shared: PluginManager = PluginManager()
  
  public func activate(workbench: Workbench) -> Void {
    plugins = PluginManager.modules.compactMap{$0.pluginClass.init()}
    plugins.forEach{$0.activate(workbench: workbench)}
  }
  
  public func deactivate() -> Void {
    plugins.forEach { $0.deactivate() }
  }
  
  
  private static var pluginDirs: [Path] {
    if let main = Path(Bundle.main.bundlePath) {
      return [main/"..", main/"Plugins"]
    }
    return []
  }
  
  private static func loadModules() -> [Module.Type] {
    return pluginDirs.compactMap {
      $0.plugins.compactMap {
        return loadModule($0)}}.flatMap{$0}
  }
  
  private static func loadModule(_ path: Path) -> Module.Type? {
    if let bundle = Bundle.init(path: path.string), bundle.load(),
      let pluginModule = bundle.principalClass as? Module.Type {
      return pluginModule
    }
    
    return nil
  }
}


fileprivate extension Path {
  var plugins: [Path] {
    let paths = try? ls().directories.filter{$0.basename().hasSuffix("plugin")}
    return paths ?? []
  }
}


