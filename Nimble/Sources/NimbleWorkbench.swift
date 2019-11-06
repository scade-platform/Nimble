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
  
  public func show(unsupported file: File) {
    viewController?.editorViewController?.show(unsupported: file)
  }
  
  public func close(document: Document) {
    if checkForSave(document) {
      viewController?.editorViewController?.close(document: document)
      document.file?.close()
      documentDidClose(document)
    }
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
  
  private func checkForSave(_ document: Document) -> Bool {
    if document.isChanged {
      let result = saveDialog(question: "Do you want to save the changes you made to \(document.title)? ", text: "Your changes will be lost if you don't save them")
      if result.save {
        if let projectDoc = projectDocument as? ProjectDocument {
          projectDoc.save(document: document)
        }
      }
      return result.close
    }
    return true
  }
  
  private func saveDialog(question: String, text: String) -> (save: Bool, close: Bool) {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Save")
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Don't Save")
    let result = alert.runModal()
    return (save: result == .alertFirstButtonReturn, close:  result == .alertThirdButtonReturn || result == .alertFirstButtonReturn)
  }
}

extension NimbleWorkbench {
  
  public var currentDocument: Document? {
    viewController?.editorViewController?.currentDocument
  }
  
  
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
  
  func documentDidSave(_ document: Document) {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.documentDidSave(document)
    }
  }
  
  func documentDidChange(_ document: Document) {
    for (id, observation) in observations {
      guard let observer = observation.observer else {
        observations.removeValue(forKey: id)
        continue
      }
      observer.documentDidChange(document)
    }
  }
}
