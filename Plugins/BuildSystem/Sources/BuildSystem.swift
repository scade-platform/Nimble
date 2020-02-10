//
//  BuildSystem.swift
//  BuildSystem
//
//  Created by Danil Kristalev on 04/12/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

public protocol BuildSystem {
  var name: String { get }
  var launcher: Launcher? { get }
  func run(in workbench: Workbench, handler: ((BuildStatus) -> Void)?)
  func clean(in workbench: Workbench, handler: (() -> Void)?)
}

public extension BuildSystem {
  func run(in workbench: Workbench) {
    self.run(in: workbench, handler: nil)
  }
  
  func clean(in workbench: Workbench) {
    self.clean(in: workbench, handler: nil)
  }
}

protocol ConsoleSupport {
   func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console?
}

extension ConsoleSupport {
  func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console? {
    let openedConsoles = workbench.openedConsoles
    guard let console = openedConsoles.filter({$0.representedObject is T}).first(where: {($0.representedObject as! T) == key}) else {
      if var newConsole = workbench.createConsole(title: title, show: false) {
        newConsole.representedObject = key
        return newConsole
      }
      return nil
    }
    console.startReadingFromBuffer()
    return console
  }
}

protocol StatusBarSupport {}

extension StatusBarSupport {
  func updateAndRemoveStatus(currentStatus: String, newStatus: String, newColor: NSColor? = nil, workbench: Workbench) {
    DispatchQueue.main.async {
      let statusBar = workbench.statusBar
      guard var cell = statusBar.leftBar.first(where: {$0.title == currentStatus}) else { return }
      if let newColor = newColor, var colorableCell = cell as? Colorable {
        colorableCell.color = newColor
      }
      cell.title = newStatus
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
      var statusBar = workbench.statusBar
      guard let cellIndex = statusBar.leftBar.firstIndex(where: {$0.title == newStatus}) else { return }
      statusBar.leftBar.remove(at: cellIndex)
    }
  }

  func addAndRemoveStatus(status: String, color: NSColor? = nil, workbench: Workbench) {
    DispatchQueue.main.async {
      let cell: StatusBarTextCell
      if let color = color {
        cell = StatusBarTextCell(title: status, color: color)
      } else {
        cell = StatusBarTextCell(title: status)
      }
      var statusBar = workbench.statusBar
      statusBar.leftBar.append(cell)
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
      var statusBar = workbench.statusBar
      guard let cellIndex = statusBar.leftBar.firstIndex(where: {$0.title == status}) else { return }
      statusBar.leftBar.remove(at: cellIndex)
    }
  }
  
  func addStatus(status: String, color: NSColor? = nil, workbench: Workbench) {
    DispatchQueue.main.async {
      let cell: StatusBarTextCell
      if let color = color {
        cell = StatusBarTextCell(title: status, color: color)
      } else {
        cell = StatusBarTextCell(title: status)
      }
      var statusBar = workbench.statusBar
      statusBar.leftBar.append(cell)
    }
  }
}

public enum BuildStatus {
  case running
  case finished
  case failed
}

public protocol Launcher {
  func launch(in workbench: Workbench, handler: ((BuildStatus, Process?) -> Void)?)
}

public extension Launcher {
  func launch(in workbench: Workbench) {
    self.launch(in: workbench, handler: nil)
  }
}

public class BuildSystemsManager {
  public static let shared = BuildSystemsManager()
  
  public private(set) var buildSystems : [BuildSystem] = []
  
  public var activeBuildSystem: BuildSystem? = nil
  
  private init() {}
  
  public func add(buildSystem: BuildSystem) {
    buildSystems.append(buildSystem)
    if activeBuildSystem == nil {
      activeBuildSystem = buildSystem
    }
  }
 
}
