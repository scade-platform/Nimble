//
//  Folder.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import Foundation

// MARK: - Folder

public class Folder: FileSystemElement {
  private var filePresenter: FilePresenter?
  
  public var observers = ObserverSet<FolderObserver>() {
    didSet {
      guard !observers.isEmpty else {
        //stop FS observing if there aren't observers
        guard let filePresenter = self.filePresenter  else { return }
        NSFileCoordinator.removeFilePresenter(filePresenter)
        self.filePresenter = nil
        return
      }
      //begin FS observing only if there is at least one observer
      guard filePresenter == nil else { return }
      let filePresenter = FilePresenter(self)
      self.filePresenter = filePresenter
      NSFileCoordinator.addFilePresenter(filePresenter)
    }
  }
  
  //TODO: sorting, reloading/FS watchig etc.
  public var content: [FileSystemElement] {
    let subfolders = try? self.subfolders()
    let files = try? self.files()
    var result : [FileSystemElement] = subfolders ?? []
    result += files ?? []
    return result
  }
  
  public var isOpened: Bool = false
  
  public override init?(path: Path) {
    guard path.isDirectory else { return nil }
    super.init(path: path)
  }
    
  public func subfolders() throws -> [Folder] {
    let dirs = try self.path.ls().directories
    return dirs.compactMap{Folder(path: $0)}.sorted{$0.name.lowercased() < $1.name.lowercased()}
  }
  
  public func files() throws -> [File] {
    let files = try self.path.ls().files
    return files.filter{$0.basename() != ".DS_Store"}.compactMap{File(path: $0)}.sorted{$0.name.lowercased() < $1.name.lowercased()}
  }
}


// MARK: - Observers

public protocol FolderObserver  {
  func folderDidChange(_ folder: Folder)
  func childDidChange(_ folder: Folder, child: FileSystemElement)
}

public extension FolderObserver {
  //default implementation
  func folderDidChange(_ folder: Folder) {}
  func childDidChange(_ folder: Folder, child: FileSystemElement) {}
}

fileprivate class FilePresenter: NSObject, NSFilePresenter  {
  let presentedElement: Folder
  
  var presentedItemURL: URL? {
    return presentedElement.path.url
  }
  
  var presentedItemOperationQueue: OperationQueue {
    return OperationQueue.main
  }
  
  init(_ presentedElement: Folder) {
    self.presentedElement = presentedElement
    super.init()
  }
  
  func presentedSubitemDidChange(at url: URL) {
    guard let path = Path(url: url), let child = FileSystemElement.of(path: path) else { return }
    presentedElement.observers.notify{$0.childDidChange(presentedElement, child: child)}
  }
  
  func presentedItemDidChange() {
    presentedElement.observers.notify{$0.folderDidChange(presentedElement)}
  }
}






