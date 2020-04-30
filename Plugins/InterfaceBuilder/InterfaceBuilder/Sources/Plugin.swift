//
//  InterfaceBuilder.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import NimbleCore

public final class Editor: Module {
  public static let plugin: NimbleCore.Plugin = Plugin()
}

final class Plugin: NimbleCore.Plugin {

  func load() {
    DocumentManager.shared.registerDocumentClass(PageDocument.self)
  }
  
  public func activate(in workbench: Workbench) {
    workbench.observers.add(observer: self)
    
    let inspector = WidgetInspector.loadFromNib()
    if let inspectorArea = workbench.inspectorArea {
      inspectorArea.add(part: inspector)
      workbench.observers.add(observer: inspector)
    }
    
    
  }
  
  public func deactivate(in workbench: Workbench) {
    workbench.observers.remove(observer: self)
  }

  private func registerResourceFolder(for project: Project) {
    project.folders.forEach {
      UserDefaults.standard.set($0.path.string, forKey: "Image Resource Folder")
    }
  }
}

extension Plugin: WorkbenchObserver {

  func workbenchWillChangeProject(_ workbench: Workbench) {
    workbench.project?.observers.remove(observer: self)
  }

  func workbenchDidChangeProject(_ workbench: Workbench) {
    if let project = workbench.project {
      project.observers.add(observer: self)
      registerResourceFolder(for: project)
    }
  }

  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    if let pageDocument = document as? PageDocument {
      pageDocument.didOpen()
    }
  }

  func workbenchDidCloseDocument(_ workbench: Workbench, document: Document) {
    if let pageDocument = document as? PageDocument {
      pageDocument.didClose()
    }
  }

}

extension Plugin: ProjectObserver {

  func projectFoldersDidChange(_ project: Project) {
    registerResourceFolder(for: project)
  }
}
