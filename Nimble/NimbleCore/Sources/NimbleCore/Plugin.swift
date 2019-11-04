//
//  Plugin.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation


public protocol Module: class {
  static var pluginClass: Plugin.Type { get }
}


public protocol Plugin: class {
  init?()
  func activate(workbench: Workbench) -> Void
  func deactivate() -> Void
}


public extension Plugin {
  var bundle: Bundle {
    return Bundle(for: type(of: self))
  }
  
  var resourcePath: Path? {
    guard let path = bundle.resourcePath else { return nil }
    return Path(path)
  }  
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
    //TODO: add user folders
    if let pluginsPath = Bundle.main.builtInPlugInsPath, let path = Path(pluginsPath) {
      return [path]
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

