//
//  OutlineView.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 19/11/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class OutlineView : NSOutlineView {
  open override func menu(for event: NSEvent) -> NSMenu? {
    let clickedRow = row(for: event)
    guard clickedRow != -1, let fileSystemElement = item(atRow: clickedRow) as? FileSystemElement else {
      return super.menu(for: event)
    }
    select(row: clickedRow)
    menu = buildMenu(for: fileSystemElement)
    return menu
  }
}

fileprivate extension OutlineView {
  
  func row(for event: NSEvent) -> Int {
    let point = convert(event.locationInWindow, from: nil)
    return row(at: point)
  }
  
  func select(row: Int) {
    if row != selectedRow {
      selectRowIndexes([row], byExtendingSelection: false)
    }
  }
  
  func buildMenu(for item: FileSystemElement) -> NSMenu {
    let menu = NSMenu()
    switch item {
    case let file as File:
      menu.addItem(createMenuItem(title: "Rename...", selector: #selector(renameAction(_:)), representedObject: file))
      menu.addItem(createMenuItem(title: "Delete file", selector: #selector(deleteAction(_:)), representedObject: file))
      break
    case let folder as Folder:
      menu.addItem(createMenuItem(title: "New File", selector: #selector(createNewFileAction(_:)), representedObject: folder))
      menu.addItem(createMenuItem(title: "Rename...", selector: #selector(renameAction(_:)), representedObject: folder))
      menu.addItem(createMenuItem(title: "New Folder...", selector: #selector(createNewFolderAction(_:)), representedObject: folder))
      menu.addItem(createMenuItem(title: "Delete Folder", selector: #selector(deleteAction(_:)), representedObject: folder))
      break
    default:
      break
    }
    return ContextMenuManager.shared.extend(menu, for: item)
  }
  
  func createMenuItem(title: String, selector: Selector?, representedObject: Any? = nil) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: selector, keyEquivalent: "")
    menuItem.representedObject = representedObject
    menuItem.target = self
    return menuItem
  }
  
  @objc func renameAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }
    showImputTextAlert(message: "Please enter a new name:", fileSystemElement, handler: {newName in
      //TODO: FileSystemElement should update path
      try? fileSystemElement.path.rename(to: newName)
      //TODO: UI should listen FS to update correctly
    })
  }
  
  @objc func deleteAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement,
          showDeleteAlert(messageText: alertMessage(for: fileSystemElement))
    else {
      return
    }
    try? fileSystemElement.path.delete()
    //TODO: UI should listen FS to update correctly
  }
  
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
  
  @objc func createNewFileAction(_ sender: NSMenuItem?) {
    guard let folder = sender?.representedObject as? Folder else {
      return
    }
    showImputTextAlert(message: "Please enter a name:", nil, handler: {name in
      guard !name.isEmpty else { return }
      let parentPath = folder.path
      try? parentPath.join(name).touch()
      //TODO: UI should listen FS to update correctly
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
      //TODO: UI should listen FS to update correctly
    })
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
    
    let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
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

