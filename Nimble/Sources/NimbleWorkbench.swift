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
  
  var projectDocument: ProjectDocument? {
    didSet {
      guard let project = projectDocument?.project else {
        return
      }
      PluginManager.shared.activate(workbench: self)
      debugArea?.add(part: ConsoleManager.shared.controllerInstance() as! WorkbenchPart)
      project.subscribe(resourceObserver: self)
    }
  }
  
  var viewController: WorkbenchViewController? {
    return self.contentViewController as? WorkbenchViewController
  }
  
  public override func windowDidLoad() {
    super.windowDidLoad()
//    if CommandLine.arguments.count > 1,
//      let path = Path(CommandLine.arguments[1]), path.isDirectory {
//      project?.add(folders: [path.url])
//    }
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
  
  public var changedFiles: [File]? {
    return self.viewController?.editorViewController?.changedFiles
  }
  
  public var project: Project? {
    return projectDocument?.project
  }
  
  public var navigatorArea: WorkbenchArea? {
    return viewController?.navigatorViewController
  }
  
  public var debugArea: WorkbenchArea? {
     return viewController?.debugViewController
  }
  
  public func open(file: File) -> Document? {
    guard let doc = try? file.open(), let d = doc else {
      let unsupportedPane = UnsupportedPane.loadFromNib()
      viewController?.editorViewController?.previewEditor(unsupportedPane, file: file)
      return nil
    }
    
    if let docController = d.contentViewController {
      self.project?.open(files: [file.path.url])
      viewController?.editorViewController?.showEditor(docController, file: file)
    }
    
    return doc
  }
  
  public func preview(file: File) {
    guard let doc = try? file.open(), let d = doc else {
      let unsupportedPane = UnsupportedPane.loadFromNib()
      viewController?.editorViewController?.previewEditor(unsupportedPane, file: file)
      return
    }
    if let docController = d.contentViewController {
      viewController?.editorViewController?.previewEditor(docController, file: file)
    }
  }
  

  public func save(file: File) {
    self.projectDocument?.save(file: file)
  }
}

extension NimbleWorkbench: ResourceObserver{
  public func changed(event: ResourceChangeEvent) {
    guard event.project === self.project, let deltas = event.deltas, !deltas.isEmpty else {
      return
    }
    deltas.filter{$0.resource is File}.filter{$0.kind == .added}.forEach{self.open(file: $0.resource as! File)}
    let changedFoldersDeltas = deltas.filter{$0.resource is Folder}.filter{$0.kind == .changed}
    for delta in changedFoldersDeltas {
      delta.deltas?.filter{$0.kind == .closed}.filter{$0.resource is File}.forEach{self.viewController?.editorViewController?.closeEditor(file: $0.resource as! File)}
      delta.deltas?.filter{$0.kind == .added}.filter{$0.resource is File}.forEach{self.preview(file: $0.resource as! File)}
    }
    let closedFilesDeltas = deltas.filter{$0.resource is File}.filter{$0.kind == .closed}
    let editor = viewController!.editorViewController!
    for delta in closedFilesDeltas {
      editor.closeEditor(file: delta.resource as! File)
    }
    if let changedItem = deltas.filter({$0.resource is File}).first(where: {$0.kind == .changed}) {
      editor.markEditor(file: changedItem.resource as! File)
    }
    if let savedItem = deltas.first(where: {$0.kind == .saved}) {
      if changedFiles?.contains(savedItem.resource as! File ) ?? false {
        editor.markEditor(file: savedItem.resource as! File, changed: false)
      }
    }
  }
}
