//
//  OutlineView.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 19/11/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class ContextOutlineView : NSOutlineView {
  
  open override func menu(for event: NSEvent) -> NSMenu? {
    let point = convert(event.locationInWindow, from: nil)
    let clickedRow = row(at: point)
    guard clickedRow != -1, var clickedItem = item(atRow: clickedRow) else {
      return super.menu(for: event)
    }
    if clickedRow != selectedRow {
      selectRowIndexes([clickedRow], byExtendingSelection: false)
    }
    if let folderItem = clickedItem as? FolderItem {
      clickedItem = folderItem.folder
    }
    return ContextMenuManager.shared.menu(for: clickedItem)
  }
  
  private func reloadSelected() {
    let selectedItem = item(atRow: selectedRow)
    if let itemParent = parent(forItem: selectedItem) {
      self.reloadItem(itemParent, reloadChildren: true)
      self.expandItem(itemParent)
    }
  }
}

 // MARK: - ContextMenuProvider

extension ContextOutlineView : ContextMenuProvider {
  
  static func menuItems(for file: File) -> [NSMenuItem] {
    var docClasses = DocumentManager.shared.selectDocumentClasses(for: file)
    let _ = docClasses.partition(by: { !$0.isDefault(for: file)})

    var openAsItems: [NSMenuItem] = docClasses.map {
      createMenuItem(title: title(of: $0), selector: #selector(openAsAction), for: file)
    }

    if openAsItems.count > 1 {
      openAsItems.insert(NSMenuItem.separator(), at: 1)
    }

    return [
      createMenuItem(title: "Show in Finder", selector: #selector(showInFinderAction), for: file),
      createMenuItem(title: "Open with External Editor", selector: #selector(openInExternalEditorAction), for: file),
      createSubMenuItem(title: "Open As", items: openAsItems),
      NSMenuItem.separator(),
      createMenuItem(title: "Rename", selector: #selector(renameAction), for: file),
      NSMenuItem.separator(),
      createMenuItem(title: "Delete", selector: #selector(deleteAction), for: file)
    ]
  }
  
  static func menuItems(for folder: Folder) -> [NSMenuItem] {
    var items = [
    createMenuItem(title: "Show in Finder", selector: #selector(showInFinderAction), for: folder),
    NSMenuItem.separator(),
    createMenuItem(title: "New File...", selector: #selector(createNewFileAction), for: folder),
    createMenuItem(title: "New Folder...", selector: #selector(createNewFolderAction), for: folder),
    NSMenuItem.separator(),
    createMenuItem(title: "Rename", selector: #selector(renameAction), for: folder),
    NSMenuItem.separator(),
    createMenuItem(title: "Delete", selector: #selector(deleteAction), for: folder)]
    
    if let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench, let project = currentWorkbench.project, project.folders.contains(folder) {
      items.append(createMenuItem(title: "Remove Folder from Project", selector: #selector(removeAction), for: folder))
    }
    return items
  }
  
  // MARK: - Menu actions
  
  @objc func removeAction(_ sender: NSMenuItem?) {
    guard let folder = sender?.representedObject as? Folder,
          let currentWorkbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench
    else {
      return
    }
    currentWorkbench.project?.remove(folder)
    self.reloadSelected()
  }
  
  @objc func openAsAction(_ sender: NSMenuItem?) {
    if let menuItem = sender {
      guard let file = menuItem.representedObject as? File else { return }

      guard let docType = DocumentManager.shared
              .selectDocumentClasses(for: file)
              .first(where: { ContextOutlineView.title(of: $0) == menuItem.title} ) else { return }

      guard let doc = DocumentManager.shared.open(file: file, docType: docType) else { return }

      if let docController = NSDocumentController.shared as? DocumentController {
        docController.openDocument(doc, display: true)
      }
    }
  }

  @objc func showInFinderAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }

    NSWorkspace.shared.activateFileViewerSelecting([fileSystemElement.url]);
  }

  @objc func openInExternalEditorAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }

    NSWorkspace.shared.open(fileSystemElement.url);
  }

  @objc func renameAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }
    showImputTextAlert(message: "Please enter a new name:", fileSystemElement, handler: {newName in
      try! fileSystemElement.path.rename(to: newName)
      self.reloadSelected()
    })
  }
  
  @objc func deleteAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement,
          showDeleteAlert(messageText: alertMessage(for: fileSystemElement))
    else {
      return
    }
    //TODO: to check the cause if it could not be deleted
    try? fileSystemElement.path.delete()
    if fileSystemElement is Folder, !fileSystemElement.exists {
      //if deleted element is folder try to remove from project
      //if a folder isn't root folder this operation will do nothing
      removeAction(sender)
    }
    if fileSystemElement is File, !fileSystemElement.exists {
      let fileCoordinator = NSFileCoordinator(filePresenter: nil)
      fileCoordinator.coordinate(writingItemAt: fileSystemElement.url, options: NSFileCoordinator.WritingOptions.forDeleting, error: nil) { _ in
        //Triger NSFilePresenter
      }
    }
    self.reloadSelected()
  }
  
  @objc func createNewFileAction(_ sender: NSMenuItem?) {
    guard let folder = sender?.representedObject as? Folder else {
      return
    }
    showImputTextAlert(message: "Please enter a name:", nil, handler: {name in
      guard !name.isEmpty else { return }
      let parentPath = folder.path
      try? parentPath.join(name).touch()
      self.reloadSelected()
    })
  }
  
  @objc func createNewFolderAction(_ sender: NSMenuItem?) {
   guard let folder = sender?.representedObject as? Folder else {
      return
    }
    showImputTextAlert(message: "Please enter a name:", nil, handler: {name in
      guard !name.isEmpty else { return }
      let parentPath = folder.path
      try? parentPath.join(name).mkdir()
      self.reloadSelected()
    })
  }
  
  // MARK: - Alerts
  
  func alertMessage(for item: FileSystemElement) -> String {
    switch item {
    case let file as File:
      return "Delete file \(file.path.string)?"
    case let folder as Folder:
      return  "Delete folder \(folder.path.string)?"
    default:
      return ""
    }
  }
  
  private func showDeleteAlert(messageText: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = messageText
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Delete")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
  }
  
  private func showImputTextAlert(message: String, _ fileSystemElement: FileSystemElement?, handler: @escaping (String) -> Void) {
    let a = NSAlert()
    a.messageText = message
    a.addButton(withTitle: "Save")
    a.addButton(withTitle: "Cancel")
    
    let inputTextField = TextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
    if let fs = fileSystemElement {
      inputTextField.placeholderString = fs.name
      inputTextField.stringValue = fs.name
    }
    a.accessoryView = inputTextField
    guard let window = NSDocumentController.shared.currentDocument?.windowForSheet else {
      return
    }
    a.beginSheetModal(for: window, completionHandler: { (modalResponse) -> Void in
      if modalResponse == .alertFirstButtonReturn {
        let enteredString = inputTextField.stringValue
        handler(enteredString)
      }
    })
  }

  private static func title(of type: Document.Type) -> String {
    return String(describing: type)
  }
  
}

fileprivate class TextField : NSTextField {
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    self.becomeFirstResponder()
  }
}
