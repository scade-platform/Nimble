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
  static var pluginClass: Plugin.Type { get }
}

// MARK: - PlugIn

public protocol Plugin: class {
  init?()
  func activate(in: Workbench) -> Void
  func deactivate(in: Workbench) -> Void
}


public extension Plugin {
  var bundle: Bundle {
    return Bundle(for: type(of: self))
  }
  
  var resources: Path {
    return bundle.resources
  }
  
  func activate(in _: Workbench) -> Void {}
  
  func deactivate(in _: Workbench) -> Void {}
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
      // Use CoreFoundation API to avoid auto-loading bundles without executables
      let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: path.string))
      let info = CFBundleGetInfoDictionary(bundle) as! [String: AnyObject]
      
      if info.keys.contains(kCFBundleExecutableKey as String),
          let bundle = Bundle(path: path.string),
          let module = bundle.principalClass as? Module.Type,
          let plugin = module.pluginClass.init() {
        
        pluginManager.plugins.append(plugin)
      }
      
      guard let resources = Path(url: CFBundleCopyResourcesDirectoryURL(bundle)) else {continue}
      let packagePath = resources / "package.yml"
      
      if packagePath.exists {
        pluginManager.packages.append(Package(path: packagePath))
      }
    }
        
    return pluginManager
  }()
  
  
  
  private var plugins: [Plugin] = []
  
  private var packages: [Package] = []

  
  
  public func activate(in workbench: Workbench) -> Void {
    plugins.forEach{ $0.activate(in: workbench) }
  }
  
  public func deactivate(in workbench: Workbench) -> Void {
    plugins.forEach{ $0.deactivate(in: workbench) }
  }
  
  public func extensions<T: Decodable>(_ type: T.Type, path: String) -> [T] {
    return packages.compactMap{
      do {
        guard let val = try $0.decode(type, keyPath: "extensions/\(path)") else { return nil }
        return val
      } catch {
        print("\(error)")
      }
      return nil
    }
  }
}


fileprivate extension Path {
  var plugins: [Path] {
    let paths = try? ls().directories.filter{$0.basename().hasSuffix("plugin")}
    return paths ?? []
  }
}


