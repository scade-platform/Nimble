//
//  Plugin.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import Yams

// MARK: - Module

public protocol Module: class {
  static var plugin: Plugin { get }
}

// MARK: - Plugin

public protocol Plugin: class {
  var id: String { get }
  func activate(in: Workbench) -> Void
  func deactivate(in: Workbench) -> Void
}


public extension Plugin {
  var id: String {
    bundle.bundleIdentifier ?? ""
  }
  
  var bundle: Bundle {
    return Bundle(for: type(of: self))
  }
  
  var resources: Path {
    return bundle.resources
  }
      
  func activate(in _: Workbench) -> Void {}
  
  func deactivate(in _: Workbench) -> Void {}
  
  func extensions<T: Decodable>(_ type: T.Type, at extensionPoint: String) -> [T] {
    return PluginManager.shared.getFromPackages(type, at: "extensions/\(id)/\(extensionPoint)")
  }
}


// MARK: - Package

public struct Package {
  public let path: Path
  
  func decode<T: Decodable>(_ type: T.Type, keyPath: String) throws -> T? {
    let result = try YAMLDecoder().decode(KeyPathDecodable<T>.self,
                                          from: String(contentsOf: path),
                                          userInfo: [.keyPath: keyPath,
                                                     .relativePath: path.parent])
    return result.value
  }
}


// MARK: - PlugIn Manager

public class PluginManager {
  private static var searchPaths: [Path] {
    //TODO: add user folders
    guard let pluginsPath = Bundle.main.builtInPlugInsPath,
          let path = Path(pluginsPath) else { return [] }
    
    return [path]
  }
  
  public static let shared: PluginManager = {
    let pluginManager = PluginManager()
        
    for path in searchPaths.flatMap({$0.plugins}) {
      // Use CoreFoundation API to avoid auto-loading bundles
      let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: path.string))
      let info = CFBundleGetInfoDictionary(bundle) as! [String: AnyObject]
      
      // First load packages to be able to resolve dependencies (TBD)
      guard let resources = Path(url: CFBundleCopyResourcesDirectoryURL(bundle)) else {continue}
      let packagePath = resources / "package.yml"
      
      if packagePath.exists {
        pluginManager.packages.append(Package(path: packagePath))
      }
      
      // Load iff a plugin contains a binary
      if info.keys.contains(kCFBundleExecutableKey as String),
          let bundle = Bundle(path: path.string),
          let module = bundle.principalClass as? Module.Type {
        
        pluginManager.plugins[module.plugin.id] = module.plugin
      }
    }
        
    return pluginManager
  }()
  
  
  
  private var packages: [Package] = []
    
  public private(set) var plugins: [String: Plugin] = [:]
  
  
  
  public func activate(in workbench: Workbench) -> Void {
    plugins.forEach{ $0.1.activate(in: workbench) }
  }
  
  public func deactivate(in workbench: Workbench) -> Void {
    plugins.forEach{ $0.1.deactivate(in: workbench) }
  }
    
  public func getFromPackages<T: Decodable>(_ type: T.Type, at path: String) -> [T] {
    return packages.compactMap{
      try? $0.decode(type, keyPath: path) ?? nil
    }
  }
}


fileprivate extension Path {
  var plugins: [Path] {
    let paths = try? ls().directories.filter{$0.basename().hasSuffix("plugin")}
    return paths ?? []
  }
}


