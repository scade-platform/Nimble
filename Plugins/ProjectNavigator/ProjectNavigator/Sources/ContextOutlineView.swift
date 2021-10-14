//
//  OutlineView.swift
//  ProjectNavigator
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
    return Self.commonMenuItems(for: file) +
      [
        NSMenuItem.separator(),
        createMenuItem(title: "Rename...", selector: #selector(renameAction), for: file),
        createMenuItem(title: "Delete File", selector: #selector(deleteAction), for: file)
      ]
  }
  
  static func menuItems(for folder: Folder) -> [NSMenuItem] {
    var documentItems: [NSMenuItem] = DocumentManager.shared.creatableDocuments.map {
      let item = NSMenuItem(title: $0.newMenuTitle, action: #selector(newDocument(_:)), keyEquivalent: "")
      item.representedObject = $0
      return item
    }
     
    documentItems.sort { $0.title < $1.title }
    
    let docItem = createSubMenuItem(title: "New File...", items: documentItems)
    docItem.representedObject = folder
    
    var items = [
      createMenuItem(title: "Show in Finder", selector: #selector(showInFinderAction), for: folder),
      NSMenuItem.separator(),
      docItem,
      createMenuItem(title: "Rename...", selector: #selector(renameAction), for: folder),
      NSMenuItem.separator(),
      createMenuItem(title: "New Folder...", selector: #selector(createNewFolderAction), for: folder),
      createMenuItem(title: "Delete Folder", selector: #selector(deleteAction), for: folder),
    ]

    if let project = NSApp.currentWorkbench?.project,
       project.folders.contains(folder) {
      items.append(createMenuItem(title: "Remove Folder from Project",
                                  selector: #selector(removeAction), for: folder))
    }
    return items
  }

  static func menuItems(for document: Document) -> [NSMenuItem] {
    guard let path = document.path,
          let file = File(path: path) else { return [] }

    return Self.commonMenuItems(for: file)
  }

  private static func commonMenuItems(for file: File) -> [NSMenuItem] {
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
      NSMenuItem.separator(),
      createMenuItem(title: "Open with External Editor", selector: #selector(openInExternalEditorAction), for: file),
      createSubMenuItem(title: "Open As", items: openAsItems),
    ]
  }
  
  // MARK: - Menu actions
  
  @objc func removeAction(_ sender: NSMenuItem?) {
    guard let folder = sender?.representedObject as? Folder,
          let workbench = NSApp.currentWorkbench else { return }

    workbench.project?.remove(folder)
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
      let _ = try? parentPath.join(name).touch()
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
      let _ = try? parentPath.join(name).mkdir()
      self.reloadSelected()
    })
  }
  
  @objc private func newDocument(_ sender: NSMenuItem?) {
    guard let docType = sender?.representedObject as? CreatableDocument.Type,
      let documentController = NSDocumentController.shared as? DocumentController else { return }
    guard let folder = sender?.parent?.representedObject as? Folder else {
      return
    }
    let parentPath = folder.path
    documentController.makeDocument(url: parentPath.url, ofType: docType)
    self.reloadSelected()
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
