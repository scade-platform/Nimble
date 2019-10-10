//
//  NimbleConsoleViewController.swift
//  NimbleConsole
//
//  Created by Danil Kristalev on 10/10/2019.
//  Copyright © 2019 Scade. All rights reserved.
//

import Cocoa
import NimbleCore

class NimbleConsoleViewController: NSViewController, ConsoleController {
  @IBOutlet weak var currentConsoleView: NSView!
  
  @IBOutlet weak var consoleSelectionButton: NSPopUpButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  func createConsole(title: String, show: Bool) -> Console {
    let newConsole = TextViewConsole(title: title)
    consoleSelectionButton.addItem(withTitle: newConsole.title)
    consoleSelectionButton.selectItem(withTitle: newConsole.title)
    currentConsoleView.removeFromSuperview()
    self.view.addSubview(newConsole.view)
    currentConsoleView = newConsole.view
    return newConsole
  }

}

public class TextViewConsole: Console{
  public var title: String
  
  private let consoleView : ConsoleTextView
  
  public var view: NSView {
    return consoleView.textView
  }
  
  public var out: String
  
  init(title: String) {
    self.title = title
    self.consoleView = ConsoleTextView()
    self.out = ""
  }
}
