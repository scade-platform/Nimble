//
//  File.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import Foundation
@_exported import Path


public class File: FileSystemElement {
  public override init?(path: Path) {
    guard path.isFile else { return nil }
    super.init(path: path)
  }
}


public class FileSystemElement {
  public var observers = ObserverSet<FileSystemElementObserver>()
  private var innerFileObserver: InnerFileObserver?
  
  public let path: Path
  
  public var url: URL {
    return path.url
  }
  
  public var name: String {
    return path.basename()
  }
  
  public var `extension`: String {
    return path.extension
  }
  
  public var exists: Bool {
    return path.exists
  }
  
  public init?(path: Path) {
    self.path = path
    self.observers.delegate = self
  }
      
  public convenience init?(path: String) {
    guard let path = Path(path) else { return nil }
    self.init(path: path)
  }
  
  public convenience init?(url: URL) {
    guard let path = Path(url: url) else { return nil }
    self.init(path: path)
  }
  
  deinit {
    guard let filePresenter = innerFileObserver else { return }
    NSFileCoordinator.removeFilePresenter(filePresenter)
  }
}


extension FileSystemElement: Hashable {
  public static func == (lhs: FileSystemElement, rhs: FileSystemElement) -> Bool {
    return lhs.path == rhs.path
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }
}

extension FileSystemElement : ObserverSetDelegate {
  
  public func observerWillAdd(_ observer: AnyObject) {
    //begin FS observing only if there is at least one observer
    guard innerFileObserver == nil else { return }
    let filePresenter = InnerFileObserver(self, observers: observers)
    self.innerFileObserver = filePresenter
    NSFileCoordinator.addFilePresenter(filePresenter)
  }
  
  public func observerDidRemove(_ observer: AnyObject) {
    stopInnerObserver()
  }
  
  public func observerDidRelease() {
    stopInnerObserver()
  }
  
  private func stopInnerObserver(){
    //stop FS observing if there aren't observers
    guard observers.isEmpty, let filePresenter = innerFileObserver else { return }
    NSFileCoordinator.removeFilePresenter(filePresenter)
    innerFileObserver = nil
  }
}

fileprivate extension FileSystemElement {
  class InnerFileObserver: NSObject, NSFilePresenter {
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue {
      return OperationQueue.main
    }
    
    let observers: ObserverSet<FileSystemElementObserver>
    let fileSystemElement: FileSystemElement
    
    
    init(_ fileSystemElement: FileSystemElement, observers: ObserverSet<FileSystemElementObserver> ) {
      self.fileSystemElement = fileSystemElement
      self.presentedItemURL = fileSystemElement.path.url
      self.observers = observers
      super.init()
    }
    
    func presentedSubitemDidChange(at url: URL) {
      observers.notify{$0.subitemDidChange(fileSystemElement, subitem: url)}
    }
    
    func presentedItemDidChange() {
      observers.notify{$0.fileSystemElementDidChange(fileSystemElement)}
    }
  }
}


public extension URL {
  var file: File? {
    guard let path = Path(url: self) else { return nil }
    return File(path: path)
  }
  
  var mime: String {
    guard let mime = UTTypeCopyPreferredTagWithClass(uti as CFString, kUTTagClassMIMEType) else { return "" }
    return mime.takeRetainedValue() as String
  }
  
  var uti: String {
     if let resourceValues = try? resourceValues(forKeys: [.typeIdentifierKey]),
       let uti = resourceValues.typeIdentifier {
         return uti
     }
     return ""
   }
  
  func typeIdentifierConforms(to: String) -> Bool {
    return UTTypeConformsTo(uti as CFString , to as CFString)
  }    
}

public protocol FileSystemElementObserver {
  func fileSystemElementDidChange(_ fileSystemElement: FileSystemElement)
  func subitemDidChange(_ fileSystemElement: FileSystemElement, subitem: URL)
}

public extension FileSystemElementObserver {
  //default implementation
  func fileSystemElementDidChange(_ fileSystemElement: FileSystemElement) {}
  func subitemDidChange(_ fileSystemElement: FileSystemElement, subitem: URL) {}
}
