//
//  Folder.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//

import Foundation

public class Folder: FileSystemElement {
  private var fsObserver: FSFolderObserver?
  
  public var observers = ObserverSet<FolderObserver>() {
    didSet {
      guard !observers.isEmpty else {
        //stop FS observing if there aren't observers
        guard let filePresenter = fsObserver  else { return }
        NSFileCoordinator.removeFilePresenter(filePresenter)
        fsObserver = nil
        return
      }
      //begin FS observing only if there is at least one observer
      guard fsObserver == nil else { return }
      let filePresenter = FSFolderObserver(self)
      self.fsObserver = filePresenter
      NSFileCoordinator.addFilePresenter(filePresenter)
    }
  }
  
  public override init?(path: Path) {
    guard path.isDirectory else { return nil }
    super.init(path: path)
  }
  
  //TODO: sorting, reloading/FS watchig etc.
  public var content: [FileSystemElement] {
    let subfolders = try? self.subfolders()
    let files = try? self.files()
    var result : [FileSystemElement] = subfolders ?? []
    result += files ?? []
    return result
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

fileprivate class FSFolderObserver: NSObject, NSFilePresenter  {
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
    presentedElement.observers.notify{$0.childDidChange(presentedElement, child: url)}
  }
  
  func presentedItemDidChange() {
    presentedElement.observers.notify{$0.folderDidChange(presentedElement)}
  }
}


public protocol FolderObserver  {
  func folderDidChange(_ folder: Folder)
  func childDidChange(_ folder: Folder, child: URL)
}

public extension FolderObserver {
  //default implementation
  func folderDidChange(_ folder: Folder) {}
  func childDidChange(_ folder: Folder, child: URL) {}
}

