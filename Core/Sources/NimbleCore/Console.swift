//
//  Console.swift
//  NimbleCore
//
//  Created by Danil Kristalev on 10/10/2019.
//

import Cocoa

public protocol Console {

  var title: String { get }

  var view: NSView { get }

  //TODO: Improv to Pipe, Stream or something else
  var out: String {set get}
}

public protocol ConsoleController: NSViewController {
  
  func createConsole(title: String, show: Bool) -> Console
  
}


public class ConsoleManager {
  
  public static let shared = ConsoleManager()
  
  private var controllerClass: ConsoleController.Type?
  
  private var loadedController: ConsoleController?
  
  public func registerControllerClass<T: ConsoleController>(_ controllerClass: T.Type) {
    self.controllerClass = controllerClass
  }
  
  public func controllerInstance() -> ConsoleController? {
    if let loaded = loadedController {
      return loaded
    }
    guard let result = controllerClass?.loadFromNib() else {
      return nil
    }
    self.loadedController = result
    return loadedController
  }
  
}


