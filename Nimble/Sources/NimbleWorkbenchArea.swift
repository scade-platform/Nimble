//
//  WorkbenchArea.swift
//  Nimble
//
//  Created by Danil Kristalev on 03.04.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

protocol NimbleWorkbenchArea: WorkbenchArea where Self: NSViewController {
  var changeVisibleCommand: Command? { get }
  var toolbarIcon: NSImage? { get }
}

extension NimbleWorkbenchArea {
  var changeVisibleCommand: Command? { nil }
  var toolbarIcon: NSImage? { nil }
}

extension NimbleWorkbenchArea {
  public var isHidden: Bool {
    set {
      guard let parent = self.parent as? NSSplitViewController else { return }
      parent.splitViewItem(for: self)?.isCollapsed = newValue
      
      changeVisibleCommand?.isSelected = !newValue
      changeVisibleCommand?.title = self.commandTitle
    }
    get {
      guard let parent = self.parent as? NSSplitViewController else { return true }
      return parent.splitViewItem(for: self)?.isCollapsed ?? true
    }
  }
}

extension NimbleWorkbenchArea {

  var commandTitle: String {
    let firstWord = isHidden ? "Show" : "Hide"
    return "\(firstWord) \(self.title ?? "")"
  }
  
  func createCommand() -> Command? {
    guard let title = self.title else { return nil }
    let command = Command(name: title, menuPath: "View", toolbarIcon: self.toolbarIcon) {[weak self] command in
      guard let area = self else { return }
      area.isHidden = !area.isHidden
      command.isSelected = !area.isHidden
      command.title = area.commandTitle
    }
    command.title = self.commandTitle
    command.isSelected = !self.isHidden
    
    return command
  }
  
  func registerCommand() -> Command? {
    if let group = CommandManager.shared.groups["WorkbenchAreaGroup"],
      let command = self.createCommand() {
      command.groupName = group.name
      CommandManager.shared.registerCommand(command: command)
      group.commands.append(command)
      return command
    }
    return nil
  }
}


