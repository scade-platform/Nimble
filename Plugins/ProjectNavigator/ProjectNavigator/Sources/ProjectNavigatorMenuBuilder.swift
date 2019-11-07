//
//  ProjectNavigatorMenuBuilder.swift
//  ProjectNavigator
//
//  Created by Danil Kristalev on 16/10/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class ProjectNavigatorMenuBuilder: MenuBuilder {
  private let workbench: Workbench
  
  init(workbench: Workbench){
    self.workbench = workbench
  }
  
  private var subMenuBuilders: [String: MenuBuilder] = [:]
  private var subMenu: [String: NSMenu] = [:]
  private var menuItems: [NSMenuItem] = []
  
  func addSubMenu(builder: MenuBuilder, title: String) -> Bool {
    guard subMenuBuilders[title] == nil, subMenu[title] == nil, !menuItems.contains(where:{$0.title == title}) else {
      return false
    }
    subMenuBuilders[title] = builder
    return true
  }
  
  func addSubMenu(menu: NSMenu, title: String) -> Bool {
    guard subMenuBuilders[title] == nil, subMenu[title] == nil, !menuItems.contains(where:{$0.title == title}) else {
      return false
    }
    subMenu[title] = menu
    return true
  }
  
  func addItem(item: NSMenuItem) -> Bool {
    let title = item.title
    guard subMenuBuilders[title] == nil, subMenu[title] == nil, !menuItems.contains(where:{$0.title == title}) else {
      return false
    }
    menuItems.append(item)
    return true
  }
  
  func removeBy(title: String) -> Any? {
    guard subMenuBuilders[title] != nil else {
      return subMenuBuilders.removeValue(forKey: title)
    }
    guard subMenu[title] != nil else {
      return subMenu.removeValue(forKey: title)
    }
    guard menuItems.contains(where:{$0.title == title}) else {
      let index = menuItems.firstIndex{$0.title == title}
      return menuItems.remove(at: index!)
    }
    return nil
  }
  
  func build(_ data: Any? = nil) -> NSMenu {
    let result = createDefaultMenu(data)
    if !menuItems.isEmpty{
      result.addItem(NSMenuItem.separator())
    }
    for item in menuItems {
      result.addItem(item.copy() as! NSMenuItem)
    }
    if !subMenuBuilders.isEmpty {
      result.addItem(NSMenuItem.separator())
    }
    for (title,builder) in subMenuBuilders {
      let menu = builder.build(data)
      let newMenuItem  = NSMenuItem(title: title, action: nil, keyEquivalent: "")
      newMenuItem.submenu = menu.copy() as? NSMenu
      result.addItem(newMenuItem)
    }
    if !subMenu.isEmpty {
      result.addItem(NSMenuItem.separator())
    }
    for (title,menu) in subMenu {
      let newMenuItem  = NSMenuItem(title: title, action: nil, keyEquivalent: "")
      newMenuItem.submenu = menu.copy() as? NSMenu
      result.addItem(newMenuItem)
    }
    return result
  }
  
  func createDefaultMenu(_ data: Any?) -> NSMenu {
    let menu = NSMenu()
    guard let fsElement = data as? FileSystemElement else {
      return menu
    }
    switch fsElement {
    case let file as File:
      menu.addItem(createMenuItem(title: "Rename...", selector: #selector(renameAction(_:)), representedObject: file))
      menu.addItem(createMenuItem(title: "Delete file", selector: #selector(deleteAction(_:)), representedObject: file))
      return menu
    case let folder as Folder:
      menu.addItem(createMenuItem(title: "New File", selector: #selector(createNewFileAction(_:)), representedObject: folder))
      menu.addItem(createMenuItem(title: "Rename...", selector: #selector(renameAction(_:)), representedObject: folder))
      menu.addItem(createMenuItem(title: "New Folder...", selector: #selector(createNewFolderAction(_:)), representedObject: folder))
      menu.addItem(createMenuItem(title: "Delete Folder", selector: #selector(deleteAction(_:)), representedObject: folder))
      return menu
    default:
      return menu
    }
  }
  
  func createMenuItem(title: String, selector: Selector?, representedObject: Any? = nil) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: selector, keyEquivalent: "")
    menuItem.representedObject = representedObject
    menuItem.target = ProjectNavigatorPlugin.menBuilder as AnyObject
    return menuItem
  }
  
  @objc func renameAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? FileSystemElement else {
      return
    }
    showRenameAlert(message: "Please enter a new name:", fileSystemElement, handler: {str in
      if !str.isEmpty, str != fileSystemElement.name {
        if let file = fileSystemElement as? File, let document = file.document {
          self.workbench.close(document: document)
        }
        fileSystemElement.rename(to: str)
        if let file = fileSystemElement as? File {
          self.workbench.preview(file: file)
        }
        self.workbench.refresh()
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
      if let document = file.document{
         ProjectController.shared.currentWorkbench?.close(document: document)
      }
    case let folder as Folder:
      result = showDeleteAlert(messageText: "Delete folder \(folder.path.string)?")
    default:
      return
    }
    guard result, (try? fileSystemElement.path.delete()) != nil else {
      return
    }
    ProjectController.shared.currentWorkbench?.refresh()
  }
  
  @objc func createNewFileAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? Folder else {
         return
       }
       showRenameAlert(message: "Please enter a name:", nil, handler: {name in
         if !name.isEmpty {
           let parentPath = fileSystemElement.path
           if (try? parentPath.join(name).touch()) != nil {
             self.workbench.refresh()
           }
         }
       })
  }
  
  @objc func createNewFolderAction(_ sender: NSMenuItem?) {
    guard let fileSystemElement = sender?.representedObject as? Folder else {
      return
    }
    showRenameAlert(message: "Please enter a name:", nil, handler: {name in
      if !name.isEmpty {
        let parentPath = fileSystemElement.path
        if (try? parentPath.join(name).mkdir()) != nil {
          self.workbench.refresh()
        }
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

