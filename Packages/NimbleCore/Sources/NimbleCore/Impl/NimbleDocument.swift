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

  private var isFilePresenter = false
    
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
      
      if let scheme = newValue?.scheme, scheme == "file" {
        if !isFilePresenter {
          NSFileCoordinator.addFilePresenter(self)
          isFilePresenter = true
        }
      } else if isFilePresenter {
        NSFileCoordinator.removeFilePresenter(self)
        isFilePresenter = false
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
    guard isFilePresenter else { return }
    NSFileCoordinator.removeFilePresenter(self)
  }
}
