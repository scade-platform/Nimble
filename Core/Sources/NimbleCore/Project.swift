//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import Yams

public class ProjectManager {
  private var _currentProject: Project = Project()
  public var currentProject: Project {
    get {
      return _currentProject
    }
    set{
      _currentProject = newValue
      notifyObservers()
    }
  }
  
  public static let shared: ProjectManager = ProjectManager()
  private var observers = [ProjectObserver]()
  
  private func notifyObservers(){
    observers.forEach{$0.changed(project: _currentProject)}
  }
  
  public func create(projectFile url : URL? = nil) -> Project {
    let newProject = Project(url: url)
    currentProject = newProject
    return newProject
  }
  
  public func subscribe(projectObserver : ProjectObserver){
    self.observers.append(projectObserver)
  }
}

public protocol ProjectObserver {
  func changed(project: Project)
}

public class Project {
  public private(set) var folders = [Folder]()
  private let location: Path?
  private let name: String?
  private var observers = [ResourceObserver]()
  
  
  init(url: URL?  = nil){
    if let url = url, let path = Path(url: url)  {
      location = path.parent
      name = path.basename(dropExtension: true)
    } else {
      location = nil
      name = nil
    }
  }
  
  public func subscribe(resourceObserver : ResourceObserver ) {
    self.observers.append(resourceObserver)
  }
  
  private func notifyResourceObservers(_ event: ResourceChangeEvent){
    observers.forEach{$0.changed(event: event)}
  }
  
  private func chargeResourceChangeEvent(type: ResourceChangeEvent.TypeEvent, deltas : [ResourceDelta]?){
    guard let deltas = deltas, !deltas.isEmpty else {
      return
    }
    notifyResourceObservers(ResourceChangeEvent(project: self, type: type, deltas: deltas))
  }
  
  public func add(folders urls: [URL]){
    guard !urls.isEmpty else {
      return
    }
    var deltas = [ResourceDelta?]()
    for url in urls {
      deltas.append(add(folder: url.path))
    }
    chargeResourceChangeEvent(type: .post, deltas: deltas.compactMap{$0})
  }
  
  
  private func add(folder: String) -> ResourceDelta? {
    if let folderPath = Path(folder) {
      guard let delta = add(folder: folderPath) else {
        return add(relativeFolder: folder)
      }
      return delta
    }
    return add(relativeFolder: folder)
  }
  
  
  private func add(folder folderPath: Path) -> ResourceDelta? {
    guard folderPath.exists && folderPath.isDirectory else {
      return nil
    }
    let newFolder = Folder(path: folderPath)
    folders.append(newFolder)
    return ResourceDelta(resource: newFolder, kind: .added)
  }
  
  private func add(relativeFolder folder: String) -> ResourceDelta? {
    guard let base = self.location else {
      return nil
    }
    let absolutPath = base.join(folder)
    return add(folder: absolutPath)
  }
  
  deinit {
    observers.removeAll()
  }
}




extension Project {
  public func read(from data: Data) -> [String]? {
    let yamlContent = String(bytes: data, encoding: .utf8)!
    guard !yamlContent.isEmpty else {
      return nil
    }
    let loadedDictionary = try? Yams.load(yaml: yamlContent) as! [String: [String]]
    if let loadedDictionary = loadedDictionary {
      var incorrectPaths = [String]()
      if let p = parse(folders : loadedDictionary){
        incorrectPaths.append(contentsOf: p)
      }
      //TODO: add files
      if !incorrectPaths.isEmpty {
        return incorrectPaths
      }
    }
    return nil
  }
  
  private func parse(folders loadedDictionary: [String: [String]]) -> [String]? {
    guard let foldersPaths = loadedDictionary[caseInsensitive: "FOLDERS"] else {
      return nil
    }
    var incorrectPaths = [String]()
    var deltas = [ResourceDelta?]()
    for folderPath in foldersPaths {
      if let delta = add(folder: folderPath){
        deltas.append(delta)
      } else {
        incorrectPaths.append(folderPath)
      }
    }
    chargeResourceChangeEvent(type: .post, deltas: deltas.compactMap{$0})
    if !incorrectPaths.isEmpty {
      return incorrectPaths
    }
    return nil
  }
  
  public func data() -> Data {
    return Data()
  }
}

public protocol ResourceObserver {
  func changed(event: ResourceChangeEvent)
}

public struct ResourceChangeEvent {
  public let project: Project
  public let type: TypeEvent
  public let deltas: [ResourceDelta]?
  
  public enum TypeEvent {
    case post
  }
}

public struct ResourceDelta {
  public let resource: FileSystemElement
  public let kind: Kind
  
  public enum Kind {
    case added
    case removed
    case changed
  }
}




private extension Dictionary where Key == String {
  
  subscript(caseInsensitive key: Key) -> Value? {
    get {
      if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
        return self[k]
      }
      return nil
    }
    set {
      if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
        self[k] = newValue
      } else {
        self[key] = newValue
      }
    }
  }
  
}
