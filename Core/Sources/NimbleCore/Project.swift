//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import Yams

public class Project {
  public private(set) var files = [File]()
  public private(set) var folders = [Folder]()
  private let location: Path?
  public let name: String?
  public var delegate: ProjectDelegate? = nil
  private var observers = [ResourceObserver]()
  
  
  public init(url: URL?  = nil){
    if let url = url, let path = Path(url: url)  {
      location = path.parent
      name = path.basename(dropExtension: true)
    } else {
      location = nil
      name = nil
    }
  }
  
  public convenience init(subscribersFrom project: Project, url: URL?  = nil) {
    self.init(url: url)
    self.observers.append(contentsOf: project.observers)
    let deltas = project.files.map{ResourceDelta(resource: $0, kind: .closed)}
    chargeResourceChangeEvent(type: .post, deltas: deltas)
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
  
  public func rename(fileSystemElement url: URL, new name: String){
    if let renamedFile = files.first(where: {$0.path.url == url}) {
      let oldPath = renamedFile.path
      let newPath = try? renamedFile.path.rename(to: name)
      guard let newUrl = newPath?.url else {
        return
      }
      close(file: oldPath.url)
      open(files: [newUrl])
    }
    if let renamedFolder = folders.first(where: {$0.path.url == url}) {
      let oldPath = renamedFolder.path
      let newPath = try? renamedFolder.path.rename(to: name)
      guard let newUrl = newPath?.url else {
        return
      }
      folders = folders.filter{$0.path.url != oldPath.url}
      performEvent(container: folders, url: oldPath.url, kind: .closed)
      add(folders: [newUrl])
    }
    
    if let (folder, element) = findElement(url) {
      let renamedFS = element
      let newPath = try? renamedFS.path.rename(to: name)
      guard let path = newPath else {
        return
      }
      if let (_, newFs) = findElement(path.url) {
        performEvent(container: folders, url: folder.path.url, kind: .changed, innerDeltas: [ResourceDelta(resource: renamedFS, kind: .closed), ResourceDelta(resource: newFs, kind: .added)])
      }
      
    }
  }
  
  private func findElement(_ url: URL) -> (rootFolder: Folder, element: FileSystemElement)? {
    for folder in folders {
      let (contains, element) = lookInto(folder: folder, url)
      if contains {
        return (folder, element!)
      }
    }
    return nil
  }
  
  private func lookInto(folder: Folder, _ url: URL) -> (contains: Bool, element: FileSystemElement?){
    guard let content = folder.content else {
      return (false, nil)
    }
    if let element = content.first(where: {$0.path.url == url}){
      return (true, element)
    }
    for subFolder in content where subFolder is Folder {
      let (contains, element) = lookInto(folder: subFolder as! Folder, url)
      if contains {
        return (true, element)
      }
    }
    return (false, nil)
  }
  
  public func add(folders urls: [URL]) {
    add(items: urls, addFunc: addFolder(_:))
  }
  
  public func open(files urls: [URL]) {
    add(items: urls, addFunc: addFile(_:))
  }
  
  public func openAll(fileSystemElements items: [URL]){
    add(folders: items)
    open(files: items)
  }
  
  public func changed(url: URL) {
    performEvent(container: files, url: url, kind: .changed)
  }
  
  public func saved(url: URL) {
    performEvent(container: files, url: url, kind: .saved)
  }
  
  public func remove(url: URL) {
    if let removedFile = files.first(where: {$0.path.url == url}){
      close(file: removedFile.path.url)
      try? removedFile.path.delete()
    }
    if let (folder, element) = findElement(url){
      try? element.path.delete()
      performEvent(container: folders, url: folder.path.url, kind: .changed, innerDeltas: [ResourceDelta(resource: element, kind: .closed)])
    }
  }
  
  public func close(file: URL) {
    let closableFils = files.filter{$0.path.url == file}
    files = files.filter{$0.path.url != file}
    closableFils.forEach{$0.close()}
    let deltas = closableFils.map{ResourceDelta(resource: $0, kind: .closed)}
    chargeResourceChangeEvent(type: .post, deltas: deltas)
  }
  
  public func build(folder: Folder) {
    delegate?.build(folder: folder)
  }
  
  
  public func runSimulator(folder: Folder){
    delegate?.runSimulator(folder: folder)
  }
  
  public func make(folder name: String, at parent: URL) {
    let parentPath = Path(url: parent)
    if let newElement = try? parentPath?.join(name).mkdir(), let (folder, element) = findElement(newElement!.url){
      performEvent(container: folders, url: folder.path.url, kind: .changed, innerDeltas: [ResourceDelta(resource: element, kind: .added)])
    }
    
  }
  
  private func performEvent(container: [FileSystemElement], url: URL, kind: ResourceDelta.Kind, innerDeltas: [ResourceDelta]? = nil){
    let fsURL = container.map{$0.path.url}
    guard fsURL.contains(url), let changedElement = container.first(where: {$0.path.url == url}) else {
      return
    }
    chargeResourceChangeEvent(type: .post, deltas: [ResourceDelta(resource: changedElement, kind: kind, deltas: innerDeltas)])
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
    let contains = target.contains{$0.path.string == item}
    guard !contains else {
      return nil
    }
    guard let path = Path(item), let delta = add(item: path, type: type, target: &target, predicate: predicate) else {
      guard let absolutePath = convertToAbsolutePath(relative: item) else {
        return nil
      }
      return add(item: absolutePath, type: type, target: &target, predicate: predicate)
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
      if let p = parse(loadedDictionary, section: "FOLDERS", addFunc: addFolder(_:)){
        incorrectPaths.append(contentsOf: p)
      }
      if let p = parse(loadedDictionary, section: "FILES", addFunc: addFile(_:)){
        incorrectPaths.append(contentsOf: p)
      }
      if !incorrectPaths.isEmpty {
        return incorrectPaths
      }
    }
    return nil
  }
  
  private func parse(_ loadedDictionary: [String: [String]], section: String, addFunc: (String) -> ResourceDelta?) -> [String]? {
    guard let itemsPaths = loadedDictionary[caseInsensitive: section] else {
      return nil
    }
    var incorrectPaths = [String]()
    var deltas = [ResourceDelta?]()
    for itemPath in itemsPaths {
      if let delta = addFunc(itemPath){
        deltas.append(delta)
      } else {
        incorrectPaths.append(itemPath)
      }
    }
    chargeResourceChangeEvent(type: .post, deltas: deltas.compactMap{$0})
    if !incorrectPaths.isEmpty {
      return incorrectPaths
    }
    return nil
  }
  
  public func data(document : NSDocument) -> Data? {
    let folders = foldersYAML(document)
    let files = filesYAML(document)
    var result = folders ?? ""
    result = result + (files ?? "")
    return result.data(using: .utf8)
  }
  
  private func foldersYAML(_ document: NSDocument) -> String? {
    guard !folders.isEmpty, let documentURL = document.fileURL else{
      return nil
    }
    return createYAML(url: documentURL, arr: folders, section: "Folders:")
  }
  
  private func filesYAML(_ document: NSDocument) -> String? {
    guard !files.isEmpty, let documentURL = document.fileURL else{
      return nil
    }
    return createYAML(url: documentURL, arr: files, section: "Files:")
  }
  
  private func createYAML(url: URL, arr: [FileSystemElement], section: String) -> String {
    let documentPath = Path(url: url)?.parent
    let result: String = arr.reduce("") { res, item in
      let relativePath = item.path.relative(to: documentPath!)
      if relativePath.isEmpty{
        return res + "  - .\n"
      }else{
        return res + ("  - \(relativePath)\n")
      }
    }
    return "\(section)\n" + result
  }
}

public protocol ProjectDelegate {
  func runSimulator(folder: Folder)
  func stopSimulator(folder: Folder)
  func runCMake(folder: Folder)
  func build(folder: Folder)
}

public extension ProjectDelegate{
  func runSimulator(folder: Folder){
    //default implementation
  }
  
  func stopSimulator(folder: Folder){
    //default implementation
  }
  
  func runCMake(folder: Folder){
    //default implementation
  }
  
  func build(folder: Folder){
    //default implementation
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
  public let deltas: [ResourceDelta]?
  
  init(resource: FileSystemElement, kind: Kind, deltas: [ResourceDelta]? = nil) {
    self.resource = resource
    self.kind = kind
    self.deltas = deltas
  }
  
  public enum Kind {
    case added
    case removed
    case changed
    case closed
    case saved
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
