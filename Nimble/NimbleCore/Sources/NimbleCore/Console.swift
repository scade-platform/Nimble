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


