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
      viewController?.editorViewController?.showEditor(docController)
    }
    
    return doc
  }
}
