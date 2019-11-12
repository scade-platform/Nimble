//
//  ProjectOutlineView.swift
//  ProjectNavigator
//
//  Created by Grigory Markin on 15.03.19.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

open class ProjectOutlineView: XibView {
  
  @IBOutlet var outline: NSOutlineView? = nil
  public var workbench: Workbench? = nil
  
  
  open override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  
  @IBAction func doubleClickedItem(_ sender: Any) {
    guard let outlineView = outline,
      let item = outlineView.item(atRow: outlineView.selectedRow) as? File else { return }
    self.workbench?.open(file: item)
  }
  
  open override func menu(for event: NSEvent) -> NSMenu? {
    guard let outline = outline else {
      return super.menu(for: event)
    }
    let point = outline.convert(event.locationInWindow, from: nil)
    let clickedRow = outline.row(at: point)
    if clickedRow == -1 {
      return super.menu(for: event)
    }
    if clickedRow != outline.selectedRow {
      outline.selectRowIndexes([clickedRow], byExtendingSelection: false)
    }
    guard let fileSystemElement = outline.item(atRow: clickedRow) as? FileSystemElement else {
      return super.menu(for: event)
    }
    menu = buildMenu(for: fileSystemElement)
    return menu
  }
}

fileprivate extension ProjectOutlineView {
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
  
  func extend(_ menu: NSMenu, for item : FileSystemElement) -> NSMenu {
    
    return menu
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
    showRenameAlert(message: "Please enter a new name:", fileSystemElement, handler: {newName in
      if !newName.isEmpty, newName != fileSystemElement.name {
        //TODO: FileSystemElement should update path
        try? fileSystemElement.path.rename(to: newName)
        //TODO: UI should listen FS to update correctly
      }
    })
  }
  
  @objc func deleteAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }
    let result: Bool
    switch fileSystemElement {
    case let file as File:
      result = showDeleteAlert(messageText: "Delete file \(file.path.string)?")
    case let folder as Folder:
      result = showDeleteAlert(messageText: "Delete folder \(folder.path.string)?")
    default:
      return
    }
    guard result, (try? fileSystemElement.path.delete()) != nil else {
      return
    }
    //TODO: UI should listen FS to update correctly
  }
  
  @objc func createNewFileAction(_ sender: NSMenuItem?) {
    guard let folder = sender?.representedObject as? Folder else {
      return
    }
    showRenameAlert(message: "Please enter a name:", nil, handler: {name in
      if !name.isEmpty {
        let parentPath = folder.path
        try? parentPath.join(name).touch()
        //TODO: UI should listen FS to update correctly
      }
    })
  }
  
  @objc func createNewFolderAction(_ sender: NSMenuItem?) {
    guard let folder = sender?.representedObject as? Folder else {
      return
    }
    showRenameAlert(message: "Please enter a name:", nil, handler: {name in
      if !name.isEmpty {
        let parentPath = folder.path
        try? parentPath.join(name).mkdir()
        //TODO: UI should listen FS to update correctly
      }
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
  
  private func showRenameAlert(message: String, _ fileSystemElement: FileSystemElement?, handler: @escaping (String) -> Void) {
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
