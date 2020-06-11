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

        if newValue?.scheme == .some("file") {
          if filePresenter == .none {
            filePresenter = DocumentFilePresenter(self)
          }
          filePresenter?.register()
        } else {
          filePresenter?.unregister()
        }

        observers.notify {
          $0.documentFileUrlDidChange(doc, oldFileUrl: oldValue)
        }
      }
    }
  }
  
  open override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool {
    savePanel.isExtensionHidden = false
    return true
  }
  
  open override func save(to url: URL,
                          ofType typeName: String,
                          for saveOperation: NSDocument.SaveOperationType,
                          completionHandler: @escaping (Error?) -> Void) {
    
    if let doc = self as? Document {
      observers.notify{
        $0.documentWillSave(doc)
      }
      doc.editor?.workbench?.willSaveDocument(doc)
    }

    filePresenter?.saveInProgress = true

    super.save(to: url, ofType: typeName, for: saveOperation) {[weak self] in
      if $0 == nil, let doc = self as? Document {
        self?.observers.notify{
          $0.documentDidSave(doc)
        }
        doc.editor?.workbench?.didSaveDocument(doc)
      }
      completionHandler($0)
    }

    filePresenter?.saveInProgress = false
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

  public var saveInProgress: Bool = false
  
  public var presentedItemOperationQueue: OperationQueue
  { return doc?.presentedItemOperationQueue ?? OperationQueue.main }

  var isRegistered = false

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
    if isRegistered && !saveInProgress {
      doc?.presentedItemDidChange()
    }
  }
}
