//
//  Folder.swift
//  NimbleCore
//
//  Created by Grigory Markin on 16.03.19.
//


public class Folder: FileSystemElement {
  
  //TODO: sorting, reloading/FS watchig etc.
  public var content: [FileSystemElement]? {
    return try? path.ls().compactMap {
      switch $0.kind {
      case .file:
        if $0.path.basename() == ".DS_Store" {
          return nil
        }
        return File(path: $0.path)
      default:
        return Folder(path: $0.path)
      }
    }.sorted{
      if type(of: $0) == type(of: $1) {
        return $0.name.lowercased() < $1.name.lowercased()
      } else {
        return $0 is Folder
      }
    }
  }
  
  public var subfolders: ChildSequence<Folder> {
    return ChildSequence<Folder>(folder: self.path, kind: .subfolders)
  }
  
  public var files: ChildSequence<File> {
    return ChildSequence<File>(folder: self.path, kind: .files)
   }
}

public extension Folder {
  
  enum ChildKind {
    case files
    case subfolders
  }
  
  struct ChildSequence<Child: FileSystemElement>: Sequence {
    fileprivate let folder: Path
    fileprivate let kind: ChildKind
    
    public func makeIterator() -> ChildIterator<Child> {
      switch kind {
      case .files:
        return ChildIterator<Child>(items: try? folder.ls().files)
      case .subfolders:
        return ChildIterator<Child>(items: try? folder.ls().directories)
      }
    }
  }
  
  struct ChildIterator<Child: FileSystemElement>: IteratorProtocol {
    private var items : [Path]
    private var index = 0

    fileprivate init(items: [Path]?) {
        self.items = items ?? []
    }

    public mutating func next() -> Child? {
      guard index < items.count else {
        return nil
      }
      let path = items[index]
      index += 1
      let child = Child.init(path: path)
      return child
    }
    
  }
}

