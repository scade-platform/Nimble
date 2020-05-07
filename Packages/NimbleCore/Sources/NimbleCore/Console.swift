//
//  Console.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 10/10/2019.
//

import Cocoa


public protocol Console {

  var title: String { get }
  
  var output: Pipe { get }
  
  var contents: String { get }
  
  var representedObject: Any? { get set }
  
  @discardableResult
  func writeLine() -> Console
  
  @discardableResult
  func write(string: String) -> Console
  
  @discardableResult
  func writeLine(string: String) -> Console
  
  @discardableResult
  func write(obj: Any?) -> Console
  
  @discardableResult
  func writeLine(obj: Any?) -> Console
  
  @discardableResult
  func write(data: Data) -> Console
  
  @discardableResult
  func writeLine(data: Data) -> Console
  
  func stopReadingFromBuffer()
  
  func startReadingFromBuffer()
  
  var isReadingFromBuffer: Bool { get }
  
  func close()
}




public extension Console {
  func writeLine() -> Console {
    return write(string: "\n")
  }
  
  func write(string: String) -> Console {
    guard let data = string.data(using: .utf8) else {
      return self
    }
    return write(data: data)
  }
  
  func writeLine(string: String) -> Console {
    return write(string: "\(string)\n")
  }
  
  func write(obj: Any?) -> Console {
    guard let someObj = obj else {
      return self
    }
    return write(string: "\(someObj)")
  }
  
  func writeLine(obj: Any?) -> Console {
    guard let someObj = obj else {
      return self
    }
    return write(string: "\(someObj)\n")
  }
  
  func writeLine(data: Data) -> Console {
    return write(data: data).writeLine()
  }
}

public class ConsoleUtils {
  public static func openConsole<T: Equatable>(key: T, title: String, in workbench: Workbench) -> Console? {
    let openedConsoles = workbench.openedConsoles
    guard let console = openedConsoles.filter({$0.title == title}).filter({$0.representedObject is T}).first(where: {($0.representedObject as! T) == key}) else {
      if var newConsole = workbench.createConsole(title: title, show: true, startReading: false) {
        newConsole.representedObject = key
        return newConsole
      }
      return nil
    }
    return console
  }
  
  public static func showConsoleTillFirstEscPress(in workbench: Workbench) {
    var escPressMonitor: Any? = nil
    escPressMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
      if event.keyCode == Keycode.escape {
        workbench.debugArea?.isHidden = true
        if let monitor = escPressMonitor {
          //only for first `esc` press
          NSEvent.removeMonitor(monitor)
          escPressMonitor = nil
        }
      }
      return event
    }
    workbench.debugArea?.isHidden = false
  }
}

