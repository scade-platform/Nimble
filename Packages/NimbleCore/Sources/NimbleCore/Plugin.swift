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
  
  func load() -> Void
  
  func activate(in: Workbench) -> Void
  
  func deactivate(in: Workbench) -> Void
  
  func restoreState(in: Workbench, coder: NSCoder) -> Void
  
  func encodeRestorableState(in: Workbench, coder: NSCoder) -> Void
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
  
  func restoreState(in: Workbench, coder: NSCoder) -> Void {}
  
  func encodeRestorableState(in: Workbench, coder: NSCoder) -> Void {}
  
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

  public var dependencies: [String] {
    do {
      return (try decode([String].self, keyPath: "dependencies")) ?? []
    } catch {
      return []
    }
  }
}


// MARK: - PlugIn Manager

public class PluginManager {
  private static var searchPaths: [Path] {
    var paths: [Path] = []
    
    if let builtInURL = Bundle.main.builtInPlugInsURL, let builtInPath = Path(url: builtInURL) {
      paths.append(builtInPath)
    }
    
    if let userPlugInPath = try? (Path.applicationSupport/"Nimble"/"PlugIns").mkdir(.p) {
      paths.append(userPlugInPath)
    }
        
    return paths
  }
  
  private static func loadBundles() -> (plugins: [String: Plugin], packages: [Package]) {
    var plugins = [String: Plugin]()
    var packages = [Package]()
    
    var bundles = [String : (path: Path, bundle: CFBundle?)]()
    var dependenciesGraph = [ArraySlice<String>]()
    var pluginIdCounter = Int(0)

    for path in searchPaths.flatMap({$0.plugins}) {
      pluginIdCounter += 1

      // Use CoreFoundation API to avoid auto-loading bundles
      let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: path.string))
      let bundleId = CFBundleGetIdentifier(bundle) as String? ?? "empty-bundle-id-\(pluginIdCounter)"

      bundles[bundleId] = (path, bundle)
      
      // First load packages to be able to resolve dependencies (TBD)
      guard let resources = Path(url: CFBundleCopyResourcesDirectoryURL(bundle)) else {continue}
      let packagePath = resources / "package.yml"
      
      if packagePath.exists {
        let package = Package(path: packagePath)
        packages.append(package)

        package.dependencies.forEach { dependenciesGraph.append([bundleId, $0]) }
      } else {
        dependenciesGraph.append([bundleId])
      }
    }

    let sortedBundleIds = Array(Algorithms.c3Merge(dependenciesGraph).reversed())

    if sortedBundleIds.isEmpty {
      Swift.debugPrint("\(#file) \(#line) ERROR: plugin dependency graph cannot be resolved")
    }

    for bundleId in (sortedBundleIds.isEmpty ? Array(bundles.keys) : sortedBundleIds) {
      if let (path, bundle) = bundles[bundleId] {

        let info = CFBundleGetInfoDictionary(bundle) as! [String: AnyObject]
        // Load iff a plugin contains a binary
        if info.keys.contains(kCFBundleExecutableKey as String),
           let bundle = Bundle(path: path.string),
           let module = bundle.principalClass as? Module.Type {
          
          plugins[module.plugin.id] = module.plugin
        }
      }
    }
        
    return (plugins, packages)
  }
  
  public static let shared = PluginManager()
    
  private init() {}

  private var packages: [Package] = []
    
  public lazy var plugins: [String: Plugin] = {
    let (plugins, packages) = PluginManager.loadBundles()
    self.packages = packages
    return plugins
  }()
  
  private lazy var lazySingleLoad: Void = {
    plugins.forEach { $0.1.load() }
    return ()
  }()
  
  public func load() -> Void {
    return lazySingleLoad
  }
  
  public func activate(in workbench: Workbench) -> Void {
    plugins.forEach{ $0.1.activate(in: workbench) }
  }
  
  public func deactivate(in workbench: Workbench) -> Void {
    plugins.forEach{ $0.1.deactivate(in: workbench) }
  }
  
  public func restoreState(in workbench: Workbench, coder: NSCoder) {
    plugins.forEach{ $0.1.restoreState(in: workbench, coder: coder) }
  }
  
  public func encodeRestorableState(in workbench: Workbench, coder: NSCoder) {
    plugins.forEach{ $0.1.encodeRestorableState(in: workbench, coder: coder) }
  }
  
  public func getFromPackages<T: Decodable>(_ type: T.Type, at path: String) -> [T] {
    return packages.compactMap{
      //try? $0.decode(type, keyPath: path) ?? nil
      do {
        return try $0.decode(type, keyPath: path)
      } catch {
        print(error)
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


