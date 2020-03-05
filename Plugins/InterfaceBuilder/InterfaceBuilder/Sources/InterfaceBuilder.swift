//
//  InterfaceBuilder.swift
//  InterfaceBuilder
//
//  Created by Grigory Markin on 18.06.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import NimbleCore
import Foundation

public final class InterfaceBuilder: Module {
  public static let plugin: Plugin = InterfaceBuilderPlugin()
}

final class InterfaceBuilderPlugin: Plugin {

  func load() {
    DocumentManager.shared.registerDocumentClass(PageDocument.self)
  }
  
  public func activate(in workbench: Workbench) {
    workbench.observers.add(observer: self)
  }
  
  public func deactivate(in workbench: Workbench) {
    workbench.observers.remove(observer: self)
  }

  private func registerResourceFolder(for project: Project) {
    project.folders.forEach {
      UserDefaults.standard.set($0.path.string, forKey: "Resource Folder")
    }
  }
}

extension InterfaceBuilderPlugin: WorkbenchObserver {

  func workbenchWillChangeProject(_ workbench: Workbench) {
    workbench.project?.observers.remove(observer: self)
  }

  func workbenchDidChangeProject(_ workbench: Workbench) {
    if let project = workbench.project {
      project.observers.add(observer: self)
      registerResourceFolder(for: project)
    }
  }

}

extension InterfaceBuilderPlugin: ProjectObserver {

  func projectFoldersDidChange(project: Project) {
    registerResourceFolder(for: project)
  }
}
