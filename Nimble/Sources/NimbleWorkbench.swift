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
    ProjectManager.shared.subscribe(projectObserver: self)
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
    guard let doc = try? file.open(), let d = doc else {
      showUnsupportedFileAlert(path: file.path.url)
      return nil
    }
    
    if let docController = d.contentViewController {
      self.project.open(files: [file.path.url])
      viewController?.editorViewController?.showEditor(docController, file: file)
    }
    
    return doc
  }
  
  public func preview(file: File) {
    guard let doc = try? file.open(), let d = doc else {
      showUnsupportedFileAlert(path: file.path.url)
      return
    }
    if let docController = d.contentViewController {
      viewController?.editorViewController?.previewEditor(docController, file: file)
    }
  }
  
  
}

extension NimbleWorkbench: ResourceObserver{
  public func changed(event: ResourceChangeEvent) {
    guard event.project === self.project, let deltas = event.deltas, !deltas.isEmpty else {
      return
    }
    deltas.filter{$0.resource is File}.filter{$0.kind == .added}.forEach{self.open(file: $0.resource as! File)}
    let closedFilesDeltas = deltas.filter{$0.resource is File}.filter{$0.kind == .closed}
    for delta in closedFilesDeltas {
      viewController?.editorViewController?.closeEditor(file: delta.resource as! File)
    }
  }
}

extension NimbleWorkbench : ProjectObserver {
  public func changed(project: Project) {
    project.subscribe(resourceObserver: self)
  }
}

extension NimbleWorkbench {
  func showUnsupportedFileAlert(path: URL){
    let alert = NSAlert()
    alert.messageText =  "Nimble can't open this file:"
    alert.informativeText = path.absoluteString
    alert.addButton(withTitle: "OK")
    alert.alertStyle = .warning
    alert.runModal()
  }
}
