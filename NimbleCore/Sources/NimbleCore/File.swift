//
//  File.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
@_exported import Path


// MARK: - File

public class File: FileSystemElement {
  private var filePresenter: FilePresenter?
  
  public var observers = ObserverSet<FileObserver>() {
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
  
  public override init?(path: Path) {
    guard path.isFile else { return nil }
    super.init(path: path)
  }
}

// MARK: - FileSystemElement

public class FileSystemElement {
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
  
  public lazy var parent: FileSystemElement?  = {
    return FileSystemElement.of(path: path.parent)
  }()
  
  public init?(path: Path) {
    self.path = path
  }
      
  public convenience init?(path: String) {
    guard let path = Path(path) else { return nil }
    self.init(path: path)
  }
  
  public convenience init?(url: URL) {
    guard let path = Path(url: url) else { return nil }
    self.init(path: path)
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

extension FileSystemElement {
  static func of(path: Path) -> FileSystemElement? {
    if path.isDirectory, let folder = Folder(path: path) {
      return folder
    } else if path.isFile, let file = File(path: path) {
      return file
    }
    return nil
  }
}


// MARK: - Observers

public protocol FileObserver {
  func fileDidChange(_ file: File)
  func fileDidMoved(_ file: File, newPath: Path)
}

fileprivate class FilePresenter: NSObject, NSFilePresenter {
  let presentedElement: File
  
  var presentedItemURL: URL? {
    return presentedElement.path.url
  }
  
  var presentedItemOperationQueue: OperationQueue {
    return OperationQueue.main
  }
  
  required init(_ presentedElement: File) {
    self.presentedElement = presentedElement
    super.init()
  }
  
  func presentedItemDidChange() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.presentedElement.observers.notify{ $0.fileDidChange(self.presentedElement) }
    }
  }

    func presentedItemDidMove(to newURL: URL) {
        guard let newPath = Path(url: newURL) else { return }
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
            self.presentedElement.observers.notify{ $0.fileDidMoved(self.presentedElement, newPath: newPath) }
        }
    }
}


// MARK: - Extensions

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
