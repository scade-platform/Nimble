//
//  Project.swift
//  StudioCore
//
//  Created by Grigory Markin on 28.02.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import Yams

public protocol ProjectControllerProtocol where Self: NSDocumentController {}

public protocol ProjectDocumentProtocol where Self: NSDocument {
  var project: Project { get }
  var workbench: Workbench? { get }
  var projectDelegate: ProjectDelegate? { get }
  var notificationCenter: ProjectNotificationCenter { get }
}

public class ProjectController {
  public static let shared = try! ProjectController()
  private let controllerInstance: ProjectControllerProtocol
  
  private init() throws {
    guard let nimbleController = NSDocumentController.shared as? ProjectControllerProtocol else {
      throw ControllerErrors.init(reason: .controllerNotFound)
    }
    self.controllerInstance = nimbleController
  }
}

public extension ProjectController {
  
  var defaultType: String? {
    return controllerInstance.defaultType
  }
  
  var currentWorkbench: Workbench? {
    guard let projectDocument = controllerInstance.currentDocument as? ProjectDocumentProtocol else {
        return nil
    }
    return projectDocument.workbench
  }
  
  func projectDocument(for workbench: Workbench) -> ProjectDocumentProtocol? {
    guard let window = workbench.window,
      let projectDocument = controllerInstance.document(for: window) as? ProjectDocumentProtocol else {
        return nil
    }
    return projectDocument
  }
  
  func project(for workbench: Workbench) -> Project? {
    return projectDocument(for: workbench)?.project
  }
}

public protocol ProjectNotificationCenter {
  func addProjectObserver(_ observer: ProjectObserver)
  func removeProjectObserver(_ observer: ProjectObserver)
}

public protocol ProjectObserver: class {
  func projectDidChanged(_ newProject: Project)
  func project(_ project: Project, didUpdated folders: [Folder])
}

public extension ProjectObserver {
  func projectDidChanged(_ newProject: Project) {}
  func project(_ project: Project, didUpdated folders: [Folder]) {}
}

@propertyWrapper
public struct ProjectObserverDelegate {
  private weak var innerObserver: ProjectObserver? = nil

  public var wrappedValue: ProjectObserver?  {
    get {return innerObserver}
    set  {
      if let notificationCenter = newValue as? ProjectNotificationCenter {
        innerObserver = notificationCenter as? ProjectObserver
      } else {
        innerObserver = nil
      }
    }
  }
  
  public init(){
    
  }
}

public protocol ProjectDelegate {
  var toolchainPath : String? { get }
  func runSimulator(folder: Folder)
  func stopSimulator(folder: Folder)
  func runCMake(folder: Folder)
  func build(folder: Folder)
}

public extension ProjectDelegate {
  func runSimulator(folder: Folder) {}
  func stopSimulator(folder: Folder) {}
  func runCMake(folder: Folder){}
  func build(folder: Folder) {}
}

public class Project {
  public private(set) var folders: [Folder] = []
  public var location: URL? = nil
  @ProjectObserverDelegate public var observer: ProjectObserver?
  public init() {}
}

public extension Project {
  func read(from data: Data, incorrectPathHandler handler : (([String]) -> Void)?) throws {
    let yamlContent = String(bytes: data, encoding: .utf8)!
    guard !yamlContent.isEmpty else {
      return
    }
    do {
      let loadingDictionary = try Yams.load(yaml: yamlContent) as? [String: [String]]
      guard let loadedDictionary = loadingDictionary else {
        throw ParserErrors(reason: .incorrectFormat)
      }
      var incorrectPaths : [String] = []
      extract(from: loadedDictionary, incorrectPaths: &incorrectPaths)
      handler?(incorrectPaths)
    } catch {
      throw ParserErrors(reason: .YAMLParseError(error))
    }
  }
  
  func data() throws -> Data {
    guard let location = location else {
      throw PathErrors(reason: .projectLocationIsNil)
    }
    let foldersPath = try createFoldersRealtivePaths(for: location)
    let yaml = foldersPath.reduce("Folders:\n") { result, path in
      return result + "  - \(path)\n"
    }
    guard let result = yaml.data(using: .utf8) else {
      throw DataErrors(reason: .stringNotConvertToUTF8Data(yaml))
    }
    return result
  }
  
  func add(folders urls: [URL]) {
    guard !urls.isEmpty else {
      return
    }
    for url in urls {
      append(folder: url.path)
    }
    observer?.project(self, didUpdated: folders)
  }
}

fileprivate extension Project {
  func extract(from dictionary: [String: [String]], incorrectPaths: inout [String]) {
    guard let items = dictionary[caseInsensitive: "FOLDERS"] else {
      return
    }
    for item in items {
      guard let _ = append(folder: item) else {
        incorrectPaths.append(item)
        continue
      }
    }
  }
  
  @discardableResult
  private func append(folder string: String) -> Folder? {
    guard let path = createExistPath(string) else {
      return nil
    }
    let folder = Folder(path: path)
    if !folders.contains(folder) {
      folders.append(folder)
      return folder
    } else {
      return folders.first(where: {$0.path.string == string})
    }
  }
  
  private func createExistPath(_ string: String) -> Path? {
    if let path = Path(string), validate(path) {
      return path
    } else if let path = convertToAbsolutePath(relative: string), validate(path) {
      return path
    }
    return nil
  }
  
  private func validate(_ path: Path) -> Bool {
    return path.exists && path.isDirectory
  }
  
  private func convertToAbsolutePath(relative path: String) -> Path? {
    guard let base = self.location, let basePath = Path(url: base) else {
      return nil
    }
    return basePath.join(path)
  }
  
  private func createFoldersRealtivePaths(for location: URL) throws -> [String] {
    guard var locationPath = Path(url: location) else {
      throw PathErrors(reason: .incorrectURL(location))
    }
    if locationPath.isFile {
      locationPath = locationPath.parent
    }
    return folders.map{ item in
      let relative = item.path.relative(to: locationPath)
      if relative.isEmpty {
        return "."
      }
      return relative
    }
  }
}

public struct ProjectError<Reason>: Error {
  public var reason: Reason
  public init(reason: Reason) {
    self.reason = reason
  }
}

extension ProjectError: CustomStringConvertible {
  public var description: String {
    return """
    Reason: \(reason)
    """
  }
}

public enum PathErrorReason {
  case incorrectURL(URL)
  case projectLocationIsNil
}

public enum DataErrorReson {
  case stringNotConvertToUTF8Data(String)
}

public enum ControllerErrorReason {
  case controllerNotFound
}

public enum ParserErrorReason {
  case YAMLParseError(Error)
  case incorrectFormat
}


typealias ControllerErrors = ProjectError<ControllerErrorReason>
typealias ParserErrors = ProjectError<ParserErrorReason>
typealias PathErrors = ProjectError<PathErrorReason>
typealias DataErrors = ProjectError<DataErrorReson>


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
