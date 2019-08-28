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
  private var viewController: WorkbenchViewController? {
    return self.contentViewController as? WorkbenchViewController
  }
  
  public override func windowDidLoad() {
    super.windowDidLoad()
    
    if CommandLine.arguments.count > 1,
      let path = Path(CommandLine.arguments[1]), path.isDirectory {
      project.add(folders: [path.url])
    }
    
    PluginManager.shared.activate(workbench: self)
    project.subscribe(resourceObserver: self)
  }
  
//  func launch() -> Void {
//    pluginManager.activate(workbench: self)
//  }
//
//  func terminate() -> Void {
//    pluginManager.deactivate()
//  }
}


extension NimbleWorkbench: Workbench {
  public var project: Project {
    return ProjectManager.shared.currentProject
  }
  
  public var navigatorArea: WorkbenchArea? {
    return viewController?.navigatorViewController
  }
  
  public func open(file: File) -> Document? {
    guard let doc = try? file.open() else {
      return nil
    }
    
    if let docController = doc?.contentViewController {
      self.project.open(files: [file.path.url])
      viewController?.editorViewController?.showEditor(docController)
    }
    
    return doc
  }
}

extension NimbleWorkbench: ResourceObserver{
  public func changed(event: ResourceChangeEvent) {
    guard event.project === self.project, let deltas = event.deltas, !deltas.isEmpty else {
      return
    }
    event.deltas?.filter{$0.resource is File}.filter{$0.kind == .added}.forEach{self.open(file: $0.resource as! File)}
  }
}
