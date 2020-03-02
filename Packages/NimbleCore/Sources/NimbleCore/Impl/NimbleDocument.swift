//
//  NimbleDocument.swift
//  NimbleCore
//
//  Created by Grigory Markin on 05.02.20.
//  Copyright © 2020 SCADE. All rights reserved.
//

import AppKit

// MARK: - Default document

open class NimbleDocument: NSDocument {
  public var observers = ObserverSet<DocumentObserver> ()

  private var filePresenter: DocumentFilePresenter? = nil

  open override var fileURL: URL? {
    get { return super.fileURL }
    set {
      let oldValue = super.fileURL
      super.fileURL = newValue
      
      if oldValue != newValue, let doc = self as? Document {
        observers.notify {
          $0.documentFileUrlDidChange(doc, oldFileUrl: oldValue)
        }
      }

      if newValue?.scheme == .some("file") {
        if filePresenter == .none {
          filePresenter = DocumentFilePresenter(self)
        }
        filePresenter?.register()
      } else {
        filePresenter?.unregister()
      }
    }
  }
  
  open override func save(to url: URL,
                          ofType typeName: String,
                          for saveOperation: NSDocument.SaveOperationType,
                          completionHandler: @escaping (Error?) -> Void) {
    
    if let doc = self as? Document {
      doc.editor?.workbench?.willSaveDocument(doc)
    }
    
    super.save(to: url, ofType: typeName, for: saveOperation) {
      if $0 == nil, let doc = self as? Document {        
        doc.editor?.workbench?.didSaveDocument(doc)
      }
      completionHandler($0)
    }
  }
  
  
  open override func updateChangeCount(_ change: NSDocument.ChangeType) {
    super.updateChangeCount(change)
    
    guard let doc = self as? Document else { return }
    observers.notify { $0.documentDidChange(doc) }
  }

  open func onFileDidChange() {
    guard let doc = self as? Document else { return }
    observers.notify { $0.documentFileDidChange(doc) }
  }

  deinit {
    filePresenter?.unregister()
  }
}

fileprivate class DocumentFilePresenter: NSObject, NSFilePresenter {
  
  private weak var doc: NimbleDocument?
  
  public var presentedItemURL: URL? { return self.doc?.presentedItemURL }
  
  public var presentedItemOperationQueue: OperationQueue
  { return doc?.presentedItemOperationQueue ?? OperationQueue.main }

  private var isRegistered = false

  public init(_ doc: NimbleDocument) {
    super.init()
    self.doc = doc
  }

  public func register() {
    if !isRegistered {
      NSFileCoordinator.addFilePresenter(self)
      isRegistered = true
    }
  }

  public func unregister() {
    if isRegistered {
      NSFileCoordinator.removeFilePresenter(self)
      isRegistered = false
    }
  }

  public func presentedItemDidChange() {
    doc?.presentedItemDidChange()
  }
}
