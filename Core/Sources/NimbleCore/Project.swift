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
    DispatchQueue.main.async {
       self.observers.forEach{$0.changed(project: self._currentProject)}
    }
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
  public private(set) var files = [File]()
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
    DispatchQueue.main.async {
      self.observers.forEach{$0.changed(event: event)}
    }
  }
  
  private func chargeResourceChangeEvent(type: ResourceChangeEvent.TypeEvent, deltas : [ResourceDelta]?){
    guard let deltas = deltas, !deltas.isEmpty else {
      return
    }
    notifyResourceObservers(ResourceChangeEvent(project: self, type: type, deltas: deltas))
  }
  
  public func add(folders urls: [URL]) {
    add(items: urls, addFunc: addFolder(_:))
  }
  
  public func add(files urls: [URL]) {
    add(items: urls, addFunc: addFile(_:))
  }
  
  private func add(items urls: [URL], addFunc: (String) -> ResourceDelta?) {
    guard !urls.isEmpty else {
      return
    }
    var deltas = [ResourceDelta?]()
    for url in urls {
      deltas.append(addFunc(url.path))
    }
    chargeResourceChangeEvent(type: .post, deltas: deltas.compactMap{$0})
  }
  
  private func addFolder(_ folder: String) -> ResourceDelta? {
    let predicate: (Path) -> Bool = { path in
      return path.exists && path.isDirectory
    }
    return add(folder, type: Folder.self, target: &folders, predicate: predicate)
  }
  
  private func addFile(_ file: String) -> ResourceDelta? {
    let predicate: (Path) -> Bool = { path in
      return path.exists && path.isFile
    }
    return add(file, type: File.self, target: &files, predicate: predicate)
  }
  
  private func add<T: FileSystemElement>(_ item: String, type : T.Type, target: inout [T], predicate: (Path) -> Bool) -> ResourceDelta? {
    guard let path = Path(item), let delta = add(item: path, type: type, target: &target, predicate: predicate) else {
      guard let absolutePath = convertToAbsolutePath(relative: item) else {
        return nil
      }
      return add(item: absolutePath, type: File.self, target: &files, predicate: predicate)
    }
    return delta
  }
  
  private func add<T: FileSystemElement>(item path: Path, type : T.Type, target: inout [T], predicate : (Path) -> Bool) -> ResourceDelta? {
    guard predicate(path) else {
      return nil
    }
    let newItem = type.init(path: path)
    target.append(newItem)
    return ResourceDelta(resource: newItem, kind: .added)
  }
  
  
  private func convertToAbsolutePath(relative path: String) -> Path? {
    guard let base = self.location else {
      return nil
    }
    return base.join(path)
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
      if let delta = addFolder(folderPath){
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
  
  public func data(document : NSDocument) -> Data? {
    guard !folders.isEmpty, let documentURL = document.fileURL else{
      return nil
    }
    let documentPath = Path(url: documentURL)?.parent
    let foldersString: String = folders.reduce("") { res, folder in
      let relativePath = folder.path.relative(to: documentPath!)
      if relativePath.isEmpty{
        return res + "  - .\n"
      }else{
        return res + ("  - \(relativePath)\n")
      }
    }
    let result = "Folders:\n" + foldersString
    return result.data(using: .utf8)
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
