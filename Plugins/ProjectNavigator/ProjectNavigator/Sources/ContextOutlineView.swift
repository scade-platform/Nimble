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
    let openWithItem =
      createSubMenuItem(title: "Open With",
                        items: [
                          createMenuItem(title: "Source Code", selector: #selector(sourceCodeAction), for: file)
                        ])


    return [
      createMenuItem(title: "Show in Finder", selector: #selector(showInFinderAction), for: file),
      createMenuItem(title: "Open with External Editor", selector: #selector(openInExternalEditorAction), for: file),
      openWithItem,
      NSMenuItem.separator(),
      createMenuItem(title: "Rename", selector: #selector(renameAction), for: file),
      NSMenuItem.separator(),
      createMenuItem(title: "Delete", selector: #selector(deleteAction), for: file)
    ]
  }
  
  static func menuItems(for folder: Folder) -> [NSMenuItem] {
    return [
      createMenuItem(title: "Show in Finder", selector: #selector(showInFinderAction), for: folder),
      NSMenuItem.separator(),
      createMenuItem(title: "New File...", selector: #selector(createNewFileAction), for: folder),
      createMenuItem(title: "New Folder...", selector: #selector(createNewFolderAction), for: folder),
      NSMenuItem.separator(),
      createMenuItem(title: "Rename", selector: #selector(renameAction), for: folder),
      NSMenuItem.separator(),
      createMenuItem(title: "Delete", selector: #selector(deleteAction), for: folder)
    ]
  }
  
  // MARK: - Menu actions
  
  @objc func sourceCodeAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }
    showImputTextAlert(message: "Please enter a new name:", fileSystemElement, handler: {newName in
      try! fileSystemElement.path.rename(to: newName)
      self.reloadSelected()
    })
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
    try? fileSystemElement.path.delete()
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
  
}

fileprivate class TextField : NSTextField {
  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    self.becomeFirstResponder()
  }
}
