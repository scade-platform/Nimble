//
//  Console.swift
//  NimbleCore
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
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

  func show()
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
    guard let console = workbench.openedConsoles
      .filter({$0.title == title})
      .filter({$0.representedObject is T})
      .first(where: {($0.representedObject as! T) == key}) else
    {
      if var newConsole = workbench.createConsole(title: title, show: true, startReading: false) {
        newConsole.representedObject = key
        return newConsole
      }

      return nil
    }
    
    console.show()
    return console
  }
  
  public static func showConsoleTillFirstEscPress(in workbench: Workbench) {
    var escPressMonitor: Any? = nil
    escPressMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {[weak workbench] event in
      if event.keyCode == Keycode.escape {
        workbench?.debugArea?.isHidden = true
        if let monitor = escPressMonitor {
          //only for first `esc` press
          NSEvent.removeMonitor(monitor)
          escPressMonitor = nil
        }
      }
      return event
    }
  }
}

