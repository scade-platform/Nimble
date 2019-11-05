//
//  NimbleWorkbench.swift
//  Nimble
//
//  Created by Grigory Markin on 01.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore


public class NimbleWorkbench: NSWindowController {
  
  private var observations = [ObjectIdentifier : Observation]()
  
  var viewController: WorkbenchViewController? {
    return self.contentViewController as? WorkbenchViewController
  }
  
  func launch() {
    PluginManager.shared.activate(workbench: self)
  }
}


extension NimbleWorkbench: Workbench {
  public var navigatorArea: WorkbenchArea? {
    return viewController?.navigatorViewController
  }
  
  public var debugArea: WorkbenchArea? {
     return viewController?.debugViewController
  }
  
  public func open(document: Document, preview: Bool) {
    viewController?.editorViewController?.open(document: document, preview: preview)
    if !preview {
      documentDidOpen(document)
    }
  }
  
  public func show(unsupported file: File, preview: Bool) {
    viewController?.editorViewController?.show(unsupported: file, preview: preview)
  }
  
  public func close(document: Document) {
    viewController?.editorViewController?.close(document: document)
  }
  
  public func createConsole(title: String, show: Bool) -> Console? {
    return viewController?.debugViewController?.consoleViewController.createConsole(title: title, show: show)
  }
  
  public func addWorkbenchObserver(_ observer: WorkbenchObserver) {
    let id = ObjectIdentifier(observer)
    observations[id] = Observation(observer: observer)
  }
   
  public func removeWorkbenchObserver(_ observer: WorkbenchObserver) {
    let id = ObjectIdentifier(observer)
    observations.removeValue(forKey: id)
  }
}

fileprivate extension NimbleWorkbench {
  struct Observation {
    weak var observer: WorkbenchObserver?
  }
}

extension NimbleWorkbench {
  func documentDidOpen(_ document: Document) {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.documentDidOpen(document)
    }
  }
  
  func documentDidClose(_ document: Document) {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.documentDidClose(document)
    }
  }
  
  func documentDidSelect(_ document: Document) {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.documentDidSelect(document)
    }
  }
}
